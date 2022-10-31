class Query < ApplicationRecord
  belongs_to :project, inverse_of: :queries
  has_many :response_items, inverse_of: :query, dependent: :destroy

  validates :text, presence: true
end
