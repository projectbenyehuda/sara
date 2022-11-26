require 'sparql/client'
require 'digest'
class ApplicationController < ActionController::Base

  helper_method :wikidata_query_as_hash
  helper_method :wikidata_count
  helper_method :textify_media_type
  helper_method :textify_source

  SARA_BROWSING_TREE_FILENAME = './sara_poc_tree.json' # TODO: un-hardcode this

  # dumping some quick prototyping code here for now # TODO: consider refactoring into other contollers
  @@sparql_headers = { 'User-Agent' => 'Ruby-Sparql-Client/1.0' }
  @@sparql_endpoint = SPARQL::Client.new("https://query.wikidata.org/sparql", headers: @@sparql_headers, read_timeout: 120)

  # create SPARQL-ready lines from fragments with our custom parameter placeholders
  def interpolate_sparql_statement(statement, params)
    return statement.gsub(/&&&(\d+)/) {|var| params[$1.to_i - 1]}
  end

  # append a WHERE clause to an existing SPARQL query
  def append_where_clause(query, new_where_clause, new_clause_params)
    clause = interpolate_sparql_statement(new_where_clause, new_clause_params) # interpolate params into clause
    # append clause to query
    return query.sub(/WHERE \{/, "WHERE {\n#{clause}") # TODO: consider using a regex to match the last WHERE clause, or otherwise handle multiple WHERE clauses
  end

  # Query Wikidata for a list of items
  def wikidata_query(query, params)
    # TODO: add caching (use a hash of the query string as key)
    interpolated_query = "SELECT ?item ?itemLabel ?itemDescription WITH { SELECT ?item "+interpolate_sparql_statement(query, params)+"} AS %i WHERE { INCLUDE %i SERVICE wikibase:label { bd:serviceParam wikibase:language \"he,en\". }}" # handle any remaining params (perhaps from base_query)
    Rails.logger.debug "Interpolated query: #{interpolated_query}"
    return @@sparql_endpoint.query(interpolated_query) # returns a collection of RDF:QUERY::Solutions
  end
  def wikidata_query_as_qid_hash(query, params)
    cache_key = "wikidata_query_as_qid_hash_#{Digest::SHA256.hexdigest(query+params.except('authenticity_token').to_s)}"
    Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      Rails.logger.debug "DBG: cache miss for cache_key #{cache_key}:\n==> query #{query+params.except('authenticity_token').to_s}\n#{Digest::SHA256.hexdigest(query+params.to_s)}"
      begin
        results = wikidata_query(query, params[:params])
      rescue
        results = {}
      end
      Rails.logger.debug("#{results.count} results")
      ret = {}
      results.each{|r| ret[r['item'].to_s.sub('http://www.wikidata.org/entity/','')] = {label: r['itemLabel'].to_s, description: r['itemLabel'].to_s}}
      ret
    end
  end
  def wikidata_query_as_hash(query)
    cache_key = "wikidata_query_as_hash_#{Digest::SHA256.hexdigest(query+params.except('authenticity_token').to_s)}"
    Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      Rails.logger.debug "DBG: cache miss for cache_key #{cache_key}:\n==> query #{query+params.except('authenticity_token').to_s}\n#{Digest::SHA256.hexdigest(query+params.to_s)}"
      begin
        results = wikidata_query(query, params[:params])
      rescue
        results = {}
      end
      Rails.logger.debug("#{results.count} results")
      ret = {}
      results.each{|r| ret[r['itemLabel'].to_s] = r['item'].to_s.sub('http://www.wikidata.org/entity/', 'wd:')}
      ret
    end
  end
  def wikidata_count(query)
    Rails.cache.fetch("wikidata_count_#{Digest::SHA256.hexdigest(query+params.except('authenticity_token').to_s)}", expires_in: 12.hours) do
      ret = -1
      interpolated_query = "SELECT (COUNT(?item) AS ?count) "+interpolate_sparql_statement(query, params) # handle any remaining params (perhaps from base_query)
      Rails.logger.debug "Running interpolated query: #{interpolated_query}"
      begin
        res = @@sparql_endpoint.query(interpolated_query) # returns a collection of RDF:QUERY::Solutions
        ret = res.first['count'].to_i
      rescue
        Rails.logger.debug "Error running query #{interpolated_query}"
      end
      ret
    end
  end
  # retrieve labels for a group of QIDs from Wikidata, with caching
  def get_labels_for_qids(qids)
    ret = {}
    uncached_qids = []
    qids.each do |qid|
      clabel = Rails.cache.read(qid)
      if clabel.present?
        ret[qid] = clabel
      else
        uncached_qids << qid
      end
    end
    Rails.logger.debug "cache hit for #{qids.length - uncached_qids.length} QIDs!"
    Rails.logger.debug "cache miss for get_labels_for_qids for #{uncached_qids.to_s}"
    uncached_qids.each_slice(50) do |qids_slice|
      RestClient.get 'https://www.wikidata.org/w/api.php', {params: {action: 'wbgetentities', ids: qids_slice.join('|'), languages: 'he', props: 'labels', format: 'json'}} do |resp, req, res, &block|
        if resp.code == 200
          json = JSON.parse(resp)
          json['entities'].each do |qid, data|
            if data['labels']['he'].present?
              ret[qid] = data['labels']['he']['value']
              Rails.cache.write(qid, data['labels']['he']['value'])
            end
          end
        else
          Rails.logger.error "Error retrieving labels for QIDs #{qids_slice.join(', ')}: #{resp}"
        end
      end
    end
    return ret
  end
  # load the SARA browsing tree JSON file
  def load_browsing_tree
    @browsing_tree = JSON.parse(File.read(SARA_BROWSING_TREE_FILENAME))
  end
  def textify_media_type(mtype)
    case mtype
    when 'text'
      return t(:text)
    when 'image'
      return t(:image)
    when 'audio'
      return t(:audio)
    when 'video'
      return t(:video)
    when 'map'
      return t(:map)
    when 'archive'
      return t(:archive)
    else
      return t(:unknown)
    end
  end
  def textify_source_license(source, item)
    case source
    when 'wikipedia'
      return t(:wikipedia_license)
    when 'nli'
      return t(:nli) # TODO: figure out how to get the license for NLI items
    when 'pby'
      return t(:pby) # TODO: grab copyright status from PBY API
    when 'commons'
      return t(:commons) # TODO: grab license from Commons item metadata
    when 'wikidata'
      return t(:wikidata_license)
    else
      return t(:unknown)
    end
  end
  def textify_citation(item)
    ret = ''
    case item['source']
    when 'wikipedia'
      ret += t(:wikipedia_citation, title: item['title'], url: item['url'])
    when 'nli'
      ret += t(:nli_citation, authors: item['authors'], year: item['normalized_year'], title: item['title'], url: item['url'])
    when 'pby'
      ret += t(:pby_citation, authors: item['authors'], year: item['normalized_year'], title: item['title'], url: item['url'])
    when 'commons'
      ret += t(:commons_citation, title: item['title'], url: item['url'])
    when 'wikidata'
      ret += t(:wikidata_citation, title: item['title'], url: item['url'])
    when 'kan'
      ret += t(:kan_citation, title: item['title'], url: item['url'])
    else
      ret += t(:unknown)
    end
  end
  def textify_source(source)
    case source
    when 'wikipedia'
      return t(:wikipedia)
    when 'nli'
      return t(:nli)
    when 'pby'
      return t(:pby)
    when 'commons'
      return t(:commons)
    when 'wikidata'
      return t(:wikidata)
    when 'kan'
      return t(:kan_source)
    else
      return t(:unknown)
    end
  end

end
