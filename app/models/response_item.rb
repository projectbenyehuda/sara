class ResponseItem < ApplicationRecord
  # We need a link for project, to keep favorite items available if parent query will be deleted
  # see https://github.com/projectbenyehuda/sara/issues/13#issuecomment-1310482546
  belongs_to :project, inverse_of: :response_items
  belongs_to :query, inverse_of: :response_items

  enum copyright: {
    unknown: 0,
    public_domain: 1,
    cc_by: 2,
    cc_by_sa: 3,
    cc_by_nd: 4,
    cc_by_nc: 5,
    cc_by_nc_sa: 6,
    cc_by_nc_nd: 7,
    cc0: 8,
    copyrighted: 9
  }
  enum source: {
    wikipedia: 1,
    nli: 2,
    pby: 3,
    wikidata: 4,
    commons: 5,
    kan: 6
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

  validates_presence_of :source, :media_type, :url, :index

  scope :without_ignored, -> {
    where(
      <<~SQL.squish
        not exists (
          select 1 from
            ignored_items i
            join queries q on q.project_id = i.project_id
          where
            q.id = response_items.query_id
            and i.external_id = response_items.external_id
            and i.source = response_items.source
        )
      SQL
    )
  }
end
