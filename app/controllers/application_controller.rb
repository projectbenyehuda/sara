require 'sparql/client'
class ApplicationController < ActionController::Base

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
    interpolated_query = interpolate_sparql_statement(query, params) # handle any remaining params (perhaps from base_query)
    return @@sparql_endpoint.query(interpolated_query) # returns a collection of RDF:QUERY::Solutions
  end

  # load the SARA browsing tree JSON file
  def load_browsing_tree
    return JSON.parse(File.read(SARA_BROWSING_TREE_FILENAME))
  end
  
end
