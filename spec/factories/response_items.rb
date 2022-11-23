FactoryBot.define do
  sequence :response_item_index

  factory :response_item do
    query
    project { query&.project }
    source { ResponseItem.sources.keys.sample }
    external_id { Faker::Internet.url }
    media_type { ResponseItem.media_types.keys.sample }
    index { generate :response_item_index }
    url { Faker::Internet.url }
    thumbnail_url { Faker::Internet.url }
    title { Faker::Book.title }
    text { Faker::Books::Lovecraft.paragraph}
  end
end
