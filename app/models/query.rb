class Query < ApplicationRecord
  validates :text, presence: true
  has_many :response_items, inverse_of: :query
end
