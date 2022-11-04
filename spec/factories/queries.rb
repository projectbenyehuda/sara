FactoryBot.define do
  factory :query do
    project
    text { Faker::Name.name }
    response_items { build_list(:response_item, 5, query: nil) }
  end
end
