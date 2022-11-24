# frozen_string_literal: true
require 'sara_utils'
module Search
  class NliSearchProvider < ApplicationService
    NLI_API_KEY = ENV['NLI_API_KEY']
    NLI_SEARCH_API_URL = 'https://api.nli.org.il/openlibrary/search'

    # Max number of result to be fetched from NLI per query
    # current implementation assumes its value to be a multiple of page size, otherwise it can return a bit more items
    NLI_MAX_RESULTS = ENV['NLI_MAX_RESULTS'].to_i || 200

    def call(query)
      result = []
      # see https://www.nli.org.il/en/research-and-teach/open-library/search-api
      begin
        # getting total number of records
        response = query_nli(query, count_mode: true)
        ctotal = JSON.parse(response)['countInfos']['total']
        total = [ctotal, NLI_MAX_RESULTS].min
        Rails.logger.info "DBG: NLI query for [#{query}] returned #{ctotal} results, of which we'll grab #{total}"
        page = 1 # page index starts from 1
        while result.size < total do
          response = query_nli(query, { result_page: page } )
          result += JSON.parse(response).map do |item|
            Search::ResponseItem.new(
              url: item['@id'].sub('https://www.nli.org.il/en/','https://www.nli.org.il/he/'),
              thumbnail_url: property_value(item, 'thumbnail'),
              external_id: property_value(item, 'recordid'),
              title: "#{property_value(item, 'creator')} / #{property_value(item, 'title')}",
              media_type: media_type_from_nli_type(property_value(item, 'type')),
              media_url: property_value(item, 'download'),
              text: property_value(item, 'format'),
              item_date: property_value(item, 'date'),
              normalized_year: normalize_year(property_value(item, 'date'))
            )
          end
          page += 1
        end
      rescue RestClient::ExceptionWithResponse => error
        # TODO: add reporting with a service like Rollbar or Sentry
        Rails.logger.error("NLI search failed: #{error.message}")
      end
      return result
    end

    def source
      return :nli
    end

    private

    def query_nli(query, additional_params)
      RestClient::Request.execute(
        method: :get,
        url: NLI_SEARCH_API_URL,
        verify_ssl: false,
        headers: {
          params: {
            api_key: NLI_API_KEY,
            query: "any,contains,#{query}&availability_type=online_and_api_access"
          }.merge(additional_params),
          content_type: :json
        }
      )
    end

    def property_value(item, property)
      val = item["http://purl.org/dc/elements/1.1/#{property}"]&.first
      return val.present? ? val['@value'] : nil
    end
    def media_type_from_nli_type(nli_type)
      case nli_type
      when 'book', 'dissertation', 'journal'
        return :text
      when 'recbroad'
        return :audio
      when 'archive'
        return :archive
      when 'image', 'sheet'
        return :image
      when 'map'
        return :map
      #when 'video'
      #  return :video
      else
        return :unknown
      end
    end
  end
end
