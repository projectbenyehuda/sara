FactoryBot.define do
  factory :query do
    text { Faker::Name.name }

    transient do
      response_items { build_list(:response_item, 5) }
    end

    after(:create) do |query, evaluator|
      query.response_items << evaluator.response_items
      query.save!
    end
  end
end
