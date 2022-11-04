FactoryBot.define do
  factory :project do
    title { Faker::Book.title }

    queries { build_list(:query, 3, project: nil) }
    ignored_items { build_list(:ignored_item, 2, project: nil) }
  end
end
