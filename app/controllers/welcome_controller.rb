require 'rest-client'

MAX_WIKIDATA_RESULTS = 400

class WelcomeController < ApplicationController
  before_action :force_json, only: [:autocomplete_by_filter_tag, :query_by_filter]

  def index

  end
  def autocomplete_by_filter_tag
    tag = params[:tag]
    phrase = params[:phrase]
    query = browsing_tree['filters']['wikidata'].find{|f| f['tag'] == tag}['lookup_query']
    if query.present?
      @sparql_results = wikidata_query_as_hash(query)
      #debugger
    else
      head 404
    end
  end
  def query_by_filter
    filter = params[:filter]
    base_query = params[:base_query]
    q = params[:q]
    query = browsing_tree['base_queries']['wikidata'].find{|f| f['tag'] == base_query}['sparql']
    if query.present?
      query = append_where_clause(query, browsing_tree['filters']['wikidata'].find{|f| f['tag'] == filter}['sparql'], [q])
      @sparql_results = wikidata_query_as_hash(query)
    else
      head 404
    end
  end
  def search
    @sara_mode = :search
  end
  def search_disambig
    @filters = {}
    unless params[:base_query].present?
      @sara_mode = :search
      @q = params[:q]
      if @q.present?
        # search Wikidata using the search action of the standard API
        RestClient.get 'https://www.wikidata.org/w/api.php', {params: {action: 'wbsearchentities', search: @q, language: 'he', uselang: 'he', type: 'item', limit: '50', format: 'json'}} do |response, request, result, &block|
          if result.class == Net::HTTPOK
            json = JSON.parse(response.body)
            search_results = json['search']
            # enrich results with images and intro paragraphs
            @results = {}
            ids = []
            search_results.each do |result|
              @results[result['id']] = {label: result.dig('display', 'label', 'value') || '', description: result.dig('display', 'description', 'value') || ''}
              ids << result['id']
            end
            prep_items(ids)
          end
        end
      else
        flash[:error] = 'לא הוזנו די פרטים'
        redirect_to root_path
      end
    else
      @sara_mode = :suggest
      @base_query = browsing_tree['base_queries']['wikidata'].find{|f| f['tag'] == params[:base_query]}
      @query = compose_query(@base_query['sparql'])
      unless @query.nil?
        count = wikidata_count(@base_query['sparql'])
        if count > 0 && count < MAX_WIKIDATA_RESULTS
          @results = wikidata_query_as_qid_hash(@base_query['sparql'],params)
          prep_items(@results.keys)
        end
      end
      unless @results.present?
        @results = []
        @topic_count = count
        flash[:error] = "לא ניתן להציג תוצאות כי יש #{count} תוצאות. יש להוסיף מסננים עד שיהיו פחות מ־#{MAX_WIKIDATA_RESULTS} תוצאות"
      else
        @sorted_keys = @results.sort_by{|item| item[1][:label]}.map{|arr| arr[0]}
      end
    end
  end
  def suggest
    @sara_mode = :suggest
    # prototyping of browsing tree
    @menu = browsing_tree['nodes']
    @base_queries = browsing_tree['base_queries']
    @filters = browsing_tree['filters']
  end
  private
  def browsing_tree
    @browsing_tree || load_browsing_tree
  end
  def force_json
    request.format = :json
  end
  def prep_items(ids)
    # get images, occupations, and life years
    @topic_count = @results.keys.count
    qids = []
    print "DBG: prepping #{ids.count} Wikidata items..."
    ids.each_slice(50) do |id_slice|
      images = {}
      print "."
      slice_ids = id_slice.join('|')
      json2 = Rails.cache.fetch("entities_#{Digest::SHA256.hexdigest(slice_ids)}", expires_in: 12.hours) do
        Rails.logger.debug "cache miss for entities for #{slice_ids}"
        RestClient.get 'https://www.wikidata.org/w/api.php', {params: {action: 'wbgetentities', ids: slice_ids, language: 'he', uselang: 'he', props: 'sitelinks|claims', format: 'json'}} do |resp, req, res, &block|
          if res.class == Net::HTTPOK
            json2 = JSON.parse(resp.body)
          end
        end
      end
      json2['entities'].keys.each do |qid|
        item = json2['entities'][qid]
        @results[qid]['instance-of'] = item['claims']['P31'].map{|c| c['mainsnak']['datavalue']['value']['id']} if item['claims'].key?('P31')
        @results[qid]['wikipedia_url'] = item['sitelinks']['hewiki'] ? 'https://he.wikipedia.org/wiki/'+item['sitelinks']['hewiki']['title'] : ''
        imagename = item['claims']['P18'] ? item['claims']['P18'][0]['mainsnak']['datavalue']['value'] : ''
        images['File:'+imagename] = qid unless imagename.empty?
        unless @results[qid]['instance-of'].nil?
          case
          when @results[qid]['instance-of'].include?('Q5') # human
            @results[qid]['birthyear'] = item['claims']['P569'] ? item['claims']['P569'][0]['mainsnak']['datavalue']['value']['time'][1..4] : ''
            @results[qid]['deathyear'] = item['claims']['P570'] ? item['claims']['P570'][0]['mainsnak']['datavalue']['value']['time'][1..4] : ''
            @results[qid]['occupations'] = item['claims']['P106'].map{|c| c['mainsnak']['datavalue']['value']['id']} if item['claims']['P106']
            @results[qid]['nationality'] = item['claims']['P27'] ? item['claims']['P27'][0]['mainsnak']['datavalue']['value']['id'] : ''
            @results[qid]['benyehuda_url'] = 'https://benyehuda.org/author/'+item['claims']['P7507'][0]['mainsnak']['datavalue']['value'] if item['claims']['P7507']
            @results[qid]['nli_id'] = item['claims']['P8189'][0]['mainsnak']['datavalue']['value'] if item['claims']['P8189']
          when @results[qid]['instance-of'].include?('Q16521'), @results[qid]['instance-of'].include?('Q7075') # organization, library
            @results[qid]['inception'] = item['claims']['P571'] ? item['claims']['P571'][0]['mainsnak']['datavalue']['value']['time'][1..4] : ''
            @results[qid]['country'] = item['claims']['P17'] ? item['claims']['P17'][0]['mainsnak']['datavalue']['value']['id'] : ''
          when @results[qid]['instance-of'].include?('Q486972') # human settlement
            @results[qid]['population'] = item['claims']['P1082'] ? item['claims']['P1082'][0]['mainsnak']['datavalue']['value']['amount'] : ''
            @results[qid]['coordinates'] = item['claims']['P625'] ? item['claims']['P625'][0]['mainsnak']['datavalue']['value'] : ''
            @results[qid]['inception'] = item['claims']['P571'] ? item['claims']['P571'][0]['mainsnak']['datavalue']['value']['time'][1..4] : ''
            @results[qid]['country'] = item['claims']['P17'] ? item['claims']['P17'][0]['mainsnak']['datavalue']['value']['id'] : ''
          end
        end
      end
      # get image thumbnail URLs
      unless images.empty?
        image_titles = images.keys.join('|')
        json3 = Rails.cache.fetch("thumbnails_#{Digest::SHA256.hexdigest(image_titles)}", expires_in: 12.hours) do
          Rails.logger.debug "cache miss for thumbnails for #{image_titles}"
          RestClient.get 'https://commons.wikimedia.org/w/api.php', {params: {action: 'query', prop: 'imageinfo', iiprop: 'url', iiurlwidth: 80, titles: image_titles, format: 'json'}} do |resp3, req3, res3, &block|
            if res3.class == Net::HTTPOK
              JSON.parse(resp3.body)['query']['pages']
            end
          end
        end
        json3.each do |page, data|
          @results[images[data['title']]]['thumbnail'] = data['imageinfo'][0]['thumburl']
        end
      end

      # get the labels for the QID values we collected
      @results.each do |qid, data|
        data.keys.each do |key|
          qids << data[key] if data[key].is_a?(String) && data[key].start_with?('Q')
          if data[key].is_a?(Array)
            data[key].each {|v| qids << v if v.start_with?('Q')}
          end
        end
      end
    end
    @labels = get_labels_for_qids(qids.uniq)
    # TODO: also fetch Wikipedia article intros?
    @timeline_data = JSON.generate(prep_timeline_data(@results))
  end
  def prep_timeline_data(results)
    timeline_data = []
    results.each do |qid, data|
      timeline_rec = { 'id' => qid, 'title' => data[:label], 'subtitle' => data[:description]}
      timeline_rec['from'] = {'year' => data['birthyear'].to_i} if data['birthyear'].present? && data['birthyear'].to_i != nil
      timeline_rec['from'] = {'year' => data['inception'].to_i} if data['inception'].present? && data['inception'].to_i != nil # mutually exclusive with birthyear
      timeline_rec['to'] = {'year' => data['deathyear'].to_i} if data['deathyear'].present? && data['deathyear'].to_i != nil
      timeline_rec['imageUrl'] = data['thumbnail'] if data['thumbnail'].present?
      timeline_data << timeline_rec if timeline_rec['to'].present? || timeline_rec['from'].present? # no point in adding records that cannot be displayed on the timeline
    end
    return timeline_data
  end
  def compose_query(base_query)
    ret = base_query
    if params[:fromdate].present? || params[:todate].present?
      @filters['date_filter'] = params[:date_filter]
      @filters['fromdate'] = params[:fromdate] if params[:fromdate].present?
      @filters['todate'] = params[:todate] if params[:todate].present?

      prop = case params[:date_filter]
      when 'birth_date'
        'wdt:P569'
      when 'death_date'
        'wdt:P570'
      when 'inception_date'
        'wdt:P571'
      end
      ret.sub!('{', "{ FILTER (YEAR(?thedate) >= #{params[:fromdate]})") if prop.present? && params[:fromdate].present?
      ret.sub!('{', "{ FILTER (YEAR(?thedate) <= #{params[:todate]})") if prop.present? && params[:todate].present?
      ret.sub!('{', "{ ?item #{prop} ?thedate . ")
    end
    if params[:gender].present?
      @filters['gender'] = params[:gender]
      if params[:gender][0] == 'Q'
        ret.sub!('{', "{ ?item wdt:P21 wd:#{params[:gender]} . ")
      else
        ret.sub!('{', '{ ?item wdt:P21 ?gender . FILTER (?gender NOT IN (wd:Q6581097, wd:Q6581072))')
      end
    end
    return ret
  end
end