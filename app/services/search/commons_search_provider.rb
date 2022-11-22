# frozen_string_literal: true
require 'mediawiki_api'

module Search
  class CommonsSearchProvider < ApplicationService
    COMMONS_SEARCH_API_URL = 'https://commons.wikimedia.org/w/api.php'
    MAX_RESULTS = 100 # can be up to 500

    def call(query)
      # see https://commons.wikimedia.org/w/api.php
      mw = MediawikiApi::Client.new(COMMONS_SEARCH_API_URL)
      # https://commons.wikimedia.org/w/api.php?action=query&format=json&prop=imageinfo&generator=search&formatversion=2&iiprop=mime%7Cthumbmime%7Curl&iiurlheight=80&gsrsearch=david%20frischmann&gsrnamespace=6&gsrlimit=100
      res = mw.query(generator: :search, gsrsearch: query, gsrnamespace: 6, gsrlimit: MAX_RESULTS, prop: :imageinfo, iiprop: [:mime, :thumbmime, :url], iiurlheight: 80, formatversion: 2)
      if res['query'].present?
        Rails.logger.info "DBG: Commons query for [#{query}] returned #{res['query']['pages'].count} results"
        res['query']['pages'].map do |item|
          Search::ResponseItem.new(
            url: iinfo(item, 'descriptionurl'),
            thumbnail_url: iinfo(item, 'thumburl'),
            external_id: iinfo(item, 'descriptionurl'),
            title: item['title'].sub('File:', ''),
            media_type: media_type_from_mime_type(iinfo(item, 'mime')),
            media_url: iinfo(item, 'url'),
            text: '' # TODO: figure out if there's a way to grab summary/description in single call
          ) # TODO: add item_date and normalized_year per https://www.mediawiki.org/wiki/Extension:CommonsMetadata
        end
      else
        Rails.logger.info "DBG: Commons query for [#{query}] returned no results"
        return []
      end
    end

    def source
      return :commons
    end
    def iinfo(item, key)
      return nil if item['imageinfo'].nil? or item['imageinfo'][0].nil?
      return item['imageinfo'][0][key]
    end

    private
    def media_type_from_mime_type(mime_type)
      case mime_type
      when 'application/pdf'
        return :text
      when /audio\//, 'application/ogg' # technically ogg files may also be video, but on Commons, oggs are audio
        return :audio
      when /image\//
        return :image
      when /video\//
        return :video
      else
        return :unknown
      end
    end
  end
end
