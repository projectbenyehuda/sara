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