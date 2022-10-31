class Project < ApplicationRecord
  has_many :queries, inverse_of: :project, dependent: :destroy
  validates :title, presence: true
end
