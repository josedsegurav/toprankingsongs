class Artist < ApplicationRecord
    has_many :albums, foreign_key: :primary_artist_id, dependent: :destroy
    has_many :tracks, foreign_key: :primary_artist_id, dependent: :destroy
    has_many :track_artists, dependent: :destroy
    has_many :featured_tracks, through: :track_artists, source: :track

    validates :name, presence: true

end
