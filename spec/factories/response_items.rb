FactoryBot.define do
  factory :response_item do
    query
    source { ResponseItem.sources.keys.sample }
    external_id { Faker::Internet.url }
    media_type { ResponseItem.media_types.keys.sample }
    index { query.present? ? (query.response_items.map(&:index).max || 0) + 1 : 1 }
    url { Faker::Internet.url }
    thumbnail_url { Faker::Internet.url }
    title { Faker::Book.title }
    text { Faker::Books::Lovecraft.paragraph}
  end
end
