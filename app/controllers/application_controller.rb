require 'sparql/client'
class ApplicationController < ActionController::Base

  helper_method :wikidata_query_as_hash
  helper_method :wikidata_count

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
    interpolated_query = "SELECT ?item ?itemLabel WITH { SELECT ?item "+interpolate_sparql_statement(query, params)+" AS %i WHERE { INCLUDE %i SERVICE wikibase:label { bd:serviceParam wikibase:language \"he,en\". }}" # handle any remaining params (perhaps from base_query)
    Rails.logger.debug "Interpolated query: #{interpolated_query}"
    return @@sparql_endpoint.query(interpolated_query) # returns a collection of RDF:QUERY::Solutions
  end

  def wikidata_query_as_hash(query)
    Rails.cache.fetch("wikidata_query_as_hash_#{query}", expires_in: 12.hours) do
      Rails.logger.debug "Running WikiData query: #{query}"
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
    Rails.cache.fetch("wikidata_count_#{query}", expires_in: 12.hours) do
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
  # retrieve labels for a group of QIDs from Wikidata
  def get_labels_for_qids(qids)
    ret = {}
    qids.each_slice(50) do |qids_slice|
      RestClient.get 'https://www.wikidata.org/w/api.php', {params: {action: 'wbgetentities', ids: qids_slice.join('|'), languages: 'he', props: 'labels', format: 'json'}} do |resp, req, res, &block|
        if resp.code == 200
          json = JSON.parse(resp)
          json['entities'].each do |qid, data|
            ret[qid] = data['labels']['he']['value'] if data['labels']['he'].present?
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
end
