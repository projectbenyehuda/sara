module ApplicationHelper
  def options_from_query(tag)
    query = @browsing_tree['filters']['wikidata'].find{|f| f['tag'] == tag}['lookup_query']
    if query.present?
      @sparql_results = wikidata_query_as_hash(query)
      opts = []
      @sparql_results.each do |item|
        opts << [item[0], item[1]]
      end
    end
  end
end
