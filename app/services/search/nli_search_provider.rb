# frozen_string_literal: true

module Search
  class NliSearchProvider < ApplicationService
    NLI_API_KEY = ENV['NLI_API_KEY']
    NLI_SEARCH_API_URL = 'https://api.nli.org.il/openlibrary/search'

    def call(query)
      # see https://www.nli.org.il/en/research-and-teach/open-library/search-api
      response = RestClient::Request.execute(
        method: :get,
        url: NLI_SEARCH_API_URL,
        verify_ssl: false,
        headers: {
          params: {
            api_key: NLI_API_KEY,
            query: "any,contains,#{query}&availability_type=online_and_api_access"
          },
          content_type: :json
        }
      )
      JSON.parse(response).map do |item|
        Search::ResponseItem.new(
          url: item['@id'],
          thumbnail_url: property_value(item, 'thumbnail'),
          external_id: property_value(item, 'recordid'),
          title: "#{property_value(item, 'creator')} / #{property_value(item, 'title')}",
          media_type: media_type_from_nli_type(property_value(item, 'type')),
          media_url: property_value(item, 'download'),
          text: property_value(item, 'format')
        )
      end
    end

    def source
      return :nli
    end

    private
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
