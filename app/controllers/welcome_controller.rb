require 'rest-client'

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
    @sara_mode = :search
    @q = params[:q]
    # search Wikidata using the search action of the standard API
    RestClient.get 'https://www.wikidata.org/w/api.php', {params: {action: 'wbsearchentities', search: @q, language: 'he', uselang: 'he', type: 'item', limit: '50', format: 'json'}} do |response, request, result, &block|
      # byebug 
      if result.class == Net::HTTPOK
        json = JSON.parse(response.body)
        @results = json['search']
        @topic_count = @results.count
        # enrich results with images and intro paragraphs
        @moredata = {}
        images = {}
        ids = ''
        @results.each do |result|
          @moredata[result['id']] = {}
          ids += result['id'] + '|'
        end
        ids = ids[0..-2] # remove trailing pipe
        # get images, occupations, and life years
        RestClient.get 'https://www.wikidata.org/w/api.php', {params: {action: 'wbgetentities', ids: ids, language: 'he', uselang: 'he', props: 'sitelinks|claims', format: 'json'}} do |resp, req, res, &block|
          if res.class == Net::HTTPOK
            json2 = JSON.parse(resp.body)
            json2['entities'].keys.each do |qid|
              item = json2['entities'][qid]
              @moredata[qid]['instance-of'] = item['claims']['P31'].map{|c| c['mainsnak']['datavalue']['value']['id']} if item['claims'].key?('P31')
              @moredata[qid]['wikipedia_url'] = item['sitelinks']['hewiki'] ? 'https://he.wikipedia.org/wiki/'+item['sitelinks']['hewiki']['title'] : ''
              imagename = item['claims']['P18'] ? item['claims']['P18'][0]['mainsnak']['datavalue']['value'] : ''
              images['File:'+imagename] = qid unless imagename.empty?
              case 
              when @moredata[qid]['instance-of'].include?('Q5') # human
                @moredata[qid]['birthyear'] = item['claims']['P569'] ? item['claims']['P569'][0]['mainsnak']['datavalue']['value']['time'][1..4] : ''
                @moredata[qid]['deathyear'] = item['claims']['P570'] ? item['claims']['P570'][0]['mainsnak']['datavalue']['value']['time'][1..4] : ''
                @moredata[qid]['occupations'] = item['claims']['P106'].map{|c| c['mainsnak']['datavalue']['value']['id']} if item['claims']['P106']
                @moredata[qid]['nationality'] = item['claims']['P27'] ? item['claims']['P27'][0]['mainsnak']['datavalue']['value']['id'] : ''
              when @moredata[qid]['instance-of'].include?('Q16521') # organization
                @moredata[qid]['inception'] = item['claims']['P571'] ? item['claims']['P571'][0]['mainsnak']['datavalue']['value']['time'][1..4] : ''
                @moredata[qid]['country'] = item['claims']['P17'] ? item['claims']['P17'][0]['mainsnak']['datavalue']['value']['id'] : ''
              when @moredata[qid]['instance-of'].include?('Q486972') # human settlement
                @moredata[qid]['population'] = item['claims']['P1082'] ? item['claims']['P1082'][0]['mainsnak']['datavalue']['value']['amount'] : ''
                @moredata[qid]['coordinates'] = item['claims']['P625'] ? item['claims']['P625'][0]['mainsnak']['datavalue']['value'] : ''
                @moredata[qid]['inception'] = item['claims']['P571'] ? item['claims']['P571'][0]['mainsnak']['datavalue']['value']['time'][1..4] : ''
                @moredata[qid]['country'] = item['claims']['P17'] ? item['claims']['P17'][0]['mainsnak']['datavalue']['value']['id'] : ''
              end
            end
            # get image thumbnail URLs
            RestClient.get 'https://commons.wikimedia.org/w/api.php', {params: {action: 'query', prop: 'imageinfo', iiprop: 'url', iiurlwidth: 80, titles: images.keys.join('|'), format: 'json'}} do |resp3, req3, res3, &block|
              if res3.class == Net::HTTPOK
                json3 = JSON.parse(resp3.body)['query']['pages']
                json3.each do |page, data|
                  @moredata[images[data['title']]]['thumbnail'] = data['imageinfo'][0]['thumburl']
                end
              end
            end
            # get the labels for the QID values we collected
            qids = []
            @moredata.each do |qid, data|
              data.keys.each do |key|
                qids << data[key] if data[key].is_a?(String) && data[key].start_with?('Q')
                if data[key].is_a?(Array)
                  data[key].each {|v| qids << v if v.start_with?('Q')}
                end
              end
            end
            @labels = get_labels_for_qids(qids.uniq)
            # TODO: also fetch Wikipedia article intros?
          end
        end
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
end