class Track < ApplicationRecord
  belongs_to :album
  belongs_to :artist, foreign_key: 'primary_artist_id'
  has_many :track_artists, dependent: :destroy
  has_many :featured_artists, through: :track_artists, source: :artist
  has_many :daily_rankings, dependent: :destroy

  validates :name, presence: true
  validates :spotify_id, presence: true, uniqueness: true
  validates :duration_ms, numericality: { greater_than: 0 }, allow_nil: true


end
