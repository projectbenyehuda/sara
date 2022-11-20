class SearchService < ApplicationService
  PROVIDERS = [Search::PbySearchProvider, Search::NliSearchProvider, Search::CommonsSearchProvider]

  def call(query)
    PROVIDERS.each do|klass|
      provider = klass.new
      items = provider.call(query.text)
      source = provider.source

      Query.transaction do
        query.response_items.where(source: source).delete_all
        items.each_with_index do |item, index|
          Rails.logger.error "DBG: can't create response item for #{item.url}!" unless query.response_items.create(
            source: source,
            index: index,
            title: item.title[0..100],
            media_url: item.media_url,
            thumbnail_url: item.thumbnail_url,
            media_type: item.media_type,
            url: item.url,
            text: item.text,
            item_date: item.item_date,
            normalized_year: item.normalized_year,
            external_id: item.external_id
          )
          
        end
      end
    end
  end
end
