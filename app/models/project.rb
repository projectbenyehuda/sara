class Project < ApplicationRecord
  has_many :response_items, inverse_of: :project, dependent: :destroy
  has_many :queries, inverse_of: :project, dependent: :destroy
  has_many :ignored_items, inverse_of: :project, dependent: :destroy
  validates :title, presence: true

  def favorite_items
    # We can have duplicates of favorite items in db (if same item was returned by different queries of same project)
    # That's why  we need an additional filter to hide duplicates (we will return only latest item from all items with
    # same external_id/source)
    # TODO: create a better solution for duplicate item, after POC is presented
    #   see https://github.com/projectbenyehuda/sara/issues/13#issuecomment-1310482546
    ResponseItem.
      where(project_id: self.id).
      where(favorite: true).
      where(
        <<~sql
          not exists (
            select 1 from
              response_items ri
            where
              ri.source = response_items.source
              and ri.external_id = response_items.external_id
              and ri.project_id = response_items.project_id
              and ri.id > response_items.id
          )
        sql
      )
  end
end
