class IgnoredItem < ApplicationRecord
  belongs_to :project, inverse_of: :ignored_items
  enum source: ResponseItem.sources
end
