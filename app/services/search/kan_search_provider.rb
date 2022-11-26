# frozen_string_literal: true
require 'sara_utils'
module Search
  class KanSearchProvider < ApplicationService
    def call(query)
      result = []
      q = query.gsub(/[0-9()–]+/, '').strip
      # see https://kan-search.azurewebsites.net/index.php?q=%D7%A0%D7%95%D7%A8%D7%99%D7%AA%20%D7%92%D7%95%D7%91%D7%A8%D7%99%D7%9F&start=0
      begin
        # getting total number of records
        url = "https://kan-search.azurewebsites.net/index.php?q=#{ERB::Util.url_encode(q)}&start=0"
        response = HTTParty.get(url)
        json = JSON.parse(response.body)
        total_results = json['total_results'] # NOTE: the Kan search page seems to lie and return n+1 for n results
        Rails.logger.debug "Kan search: #{total_results.to_i - 1} results for query #{q}"
        # getting records
        result += json['items'].map do |item|
          Search::ResponseItem.new(
            title: item['title'],
            url: item['url'],
            external_id: item['url'],
            text: item['description'],
            media_type: media_type_from_kan_type(item['metatag_type']),
            thumbnail_url: item['metatag_image']
          )
        end
        result.reject!{|item| item.media_type == :reject}
      rescue Exception => error
        # TODO: add reporting with a service like Rollbar or Sentry
        Rails.logger.error("Kan search failed: #{error.message}")
      end
      return result
    end

    def source
      return :kan
    end

    private
    def media_type_from_kan_type(kan_type)
      case kan_type
      when 'podcast', 'music.song' # this includes podcasts!
        return :audio
      when 'article'
        return :text
      when 'website' # those are not real items, but links to category and tag queries
        return :reject
      else
        return :unknown
      end
    end
  end
end
