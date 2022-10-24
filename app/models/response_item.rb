class ResponseItem < ApplicationRecord
  belongs_to :query, inverse_of: :response_items

  enum source: {
    wikipedia: 1,
    nli: 2,
    pby: 3,
    wikidata: 4
  }, _prefix: true

  enum media_type: {
    text: 1,
    image: 2,
    audio: 3,
    video: 4
  }, _prefix: true

  validates_presence_of :query, :source, :media_type, :url, :index
end
