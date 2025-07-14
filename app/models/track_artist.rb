class TrackArtist < ApplicationRecord
  belongs_to :track
  belongs_to :artist

  validates :track_id, uniqueness: { scope: :artist_id }

  scope :primary, -> { where(is_primary: true) }
  scope :featured, -> { where(is_primary: false) }
end
