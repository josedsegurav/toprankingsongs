class TracksController < ApplicationController
    def index
        @tracks = Track.includes(:artist, :album, daily_rankings: :country).all
        @track_country_counts = Track.joins(:daily_rankings)
                                .group('tracks.id')
                                .distinct
                                .count('daily_rankings.country_id')
    end

    def show
        @track = Track.includes(:artist, :album, daily_rankings: :country).find(params[:id])
        @track_country_counts = @track.daily_rankings
                                  .joins(:country)
                                  .group('countries.name')
                                  .count
    end
end
