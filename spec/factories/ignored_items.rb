FactoryBot.define do
  factory :ignored_item do
    project
    external_id { Faker::Internet.url }
    source { ResponseItem.sources.keys.sample }
  end
end
