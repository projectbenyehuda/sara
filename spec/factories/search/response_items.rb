FactoryBot.define do
  factory :search_response_item, class: Search::ResponseItem do
    media_type { ResponseItem.media_types.keys.sample }
    url { Faker::Internet.url }
    thumbnail_url { Faker::Internet.url }
    title { Faker::Book.title }
    text { Faker::Books::Lovecraft.paragraph}
  end
end
