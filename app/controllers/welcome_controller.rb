class WelcomeController < ApplicationController
  def index

    # prototyping of browsing tree
    #debugger
    @browsing_tree = load_browsing_tree
    @menu = @browsing_tree['nodes']
    @base_queries = @browsing_tree['base_queries']
    @filters = @browsing_tree['filters']
  end
  def query_by_filter
    
  end
end