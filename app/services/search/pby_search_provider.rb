# frozen_string_literal: true

module Search
  class PbySearchProvider < ApplicationService
    PBY_SEARCH_API_URL = 'https://benyehuda.org/api/v1/search'

    PBY_API_KEY = ENV['PBY_API_KEY']

    # see https://benyehuda.org/api-docs/index.html#operations-tag-search
    def call(query)
      page = 1
      result = []
      begin
        response = RestClient.post(
          PBY_SEARCH_API_URL,
          {
            key: PBY_API_KEY,
            view: :basic,
            snippet: true,
            fulltext: query,
            page: page,
          }.to_json,
          { content_type: :json }
        )
        response = JSON.parse(response)
        total = response['total_count']
        result += response['data'].map do |rec|
          metadata = rec['metadata']
          Search::ResponseItem.new(
            title: metadata['title'],
            media_url: metadata['url'],
            media_type: :text,
            url: rec['url'],
            text: rec['snippet'],
            external_id: rec['id']
          )
        end
        page += 1
      end while result.size < total && page < 5 # limit search to first 100 texts only
      return result
    end

    def source
      return :pby
    end
  end
end
