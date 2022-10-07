class SearchService < ApplicationService
  PROVIDERS = [Search::PbySearchProvider]

  def call(query)
    PROVIDERS.each do|klass|
      provider = klass.new
      items = provider.call(query.text)
      source = provider.source

      Query.transaction do
        query.response_items.where(source: source).delete_all
        items.each_with_index do |item, index|
          query.response_items.create!(
            source: source,
            index: index,
            title: item.title,
            media_url: item.media_url,
            thumbnail_url: item.thumbnail_url,
            media_type: item.media_type,
            url: item.url,
            text: item.text,
            external_id: item.external_id
          )
        end
      end
    end
  end
end
