class Album < ApplicationRecord
  belongs_to :artist, foreign_key: 'primary_artist_id'
  has_many :tracks, dependent: :destroy

  validates :title, presence: true

  scope :recent, -> { order(release_date: :desc) }
  scope :by_year, ->(year) { where(release_date: Date.new(year)..Date.new(year).end_of_year) }
end
