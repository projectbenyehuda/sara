class Project < ApplicationRecord
  has_many :queries, inverse_of: :project, dependent: :destroy
  has_many :ignored_items, inverse_of: :project, dependent: :destroy
  validates :title, presence: true
end
