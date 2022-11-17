FactoryBot.define do
  factory :query do
    transient do
      response_items_count { 5 }
    end

    project
    text { Faker::Name.name }

    after(:build) do |query, evaluator|
      query.response_items = build_list(:response_item, evaluator.response_items_count, project: query.project, query: query)
    end
  end
end
