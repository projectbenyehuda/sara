class ResponseItem < ApplicationRecord
  belongs_to :query, inverse_of: :response_items

  enum source: {
    wikipedia: 1,
    nli: 2,
    pby: 3,
    wikidata: 4,
    commons: 5
  }, _prefix: true

  enum media_type: {
    text: 1,
    image: 2,
    audio: 3,
    video: 4,
    map: 5,
    archive: 6,
    unknown: 7
  }, _prefix: true

  validates_presence_of :query, :source, :media_type, :url, :index

  scope :without_ignored, -> {
    where(<<~sql.squish
        not exists (
          select 1 from
            ignored_items i
            join queries q on q.project_id = i.project_id
          where
            q.id = response_items.query_id
            and i.external_id = response_items.external_id
            and i.source = response_items.source
        )
      sql
    )
  }
end
