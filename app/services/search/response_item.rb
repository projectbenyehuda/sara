# Simple model to represent single item in search query response
module Search
  class ResponseItem
    include ActiveModel::API
    include ActiveModel::Attributes
    attr_accessor :title, :media_url, :thumbnail_url, :media_type, :url, :text, :external_id, :item_date, :normalized_year
  end
end
