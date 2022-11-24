# frozen_string_literal: true

module Search
  class PbySearchProvider < ApplicationService
    PBY_SEARCH_API_URL = 'https://benyehuda.org/api/v1/search'

    PBY_API_KEY = ENV['PBY_API_KEY']

    # Max number of items to be fetched from PBY
    # current implementation assumes its value to be a multiple of page size, otherwise it can return a bit more items
    PBY_MAX_RESULTS = ENV['PBY_MAX_RESULTS'].to_i || 200

    # see https://benyehuda.org/api-docs/index.html#operations-tag-search
    def call(query)
      page = 1
      result = []
      q = query.gsub(/[0-9()–]+/, '').strip
      begin
        response = RestClient.post(
          PBY_SEARCH_API_URL,
          {
            key: PBY_API_KEY,
            view: :basic,
            snippet: true,
            fulltext: "\"#{q}\"",
            page: page,
          }.to_json,
          { content_type: :json }
        )
        response = JSON.parse(response)
        total = [response['total_count'], PBY_MAX_RESULTS].min
        Rails.logger.info "DBG: PBY query for [#{q}] returned #{response['total_count']} results, of which we'll grab #{total}" if page == 1
        result += response['data'].map do |rec|
          metadata = rec['metadata']
          Search::ResponseItem.new(
            title: "#{metadata['title']} / #{metadata['author_string']}",
            media_url: metadata['url'],
            media_type: :text,
            url: rec['url'],
            text: rec['snippet'],
            item_date: metadata['orig_publication_date'],
            normalized_year: normalize_year(metadata['orig_publication_date']),
            external_id: rec['id']
          )
        end
        page += 1
      end while result.size < total
      return result
    end

    def source
      return :pby
    end
  end
end
