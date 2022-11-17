FactoryBot.define do
  factory :project do
    title { Faker::Book.title }

    transient do
      queries_count { 3 }
    end

    ignored_items { build_list(:ignored_item, 2, project: nil) }

    after(:build) do |project, evaluator|
      project.queries = build_list(:query, evaluator.queries_count, project: project)
    end
  end
end
