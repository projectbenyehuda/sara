class Query < ApplicationRecord
  has_many :response_items, inverse_of: :query
end
