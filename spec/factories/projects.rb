FactoryBot.define do
  factory :project do
    title { Faker::Book.title }

    transient do
      queries { build_list(:query, 3) }
    end

    after(:create) do |project, evaluator|
      project.queries << evaluator.queries
      project.save!
    end
  end
end
