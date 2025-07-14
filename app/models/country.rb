class Country < ApplicationRecord
    has_many :daily_rankings, dependent: :destroy

    validates :iso_code, presence: true, uniqueness: true, length: { is: 2 }
    validates :name, presence: true

    scope :with_rankings, -> { joins(:daily_rankings).distinct }
end
