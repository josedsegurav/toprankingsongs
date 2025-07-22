class CountriesController < ApplicationController

  before_action :set_country, only: [:show]

  def index
    @countries = Country.includes(:daily_rankings).all
     end

  def show
    @recent_rankings = @country.daily_rankings
                               .includes(track: [:artist, :album])
                               .order(snapshot_date: :desc, daily_rank: :asc)
                               .limit(50)

    # Get top 10 tracks for this country
    @top_tracks = Track.joins(:daily_rankings)
                      .where(daily_rankings: { country: @country })
                      .group('tracks.id')
                      .select('tracks.*, AVG(daily_rankings.daily_rank) as avg_rank')
                      .includes(:artist, :album)
                      .order('avg_rank ASC')
                      .limit(10)

    # Get ranking statistics
    @total_rankings = @country.daily_rankings.count
    @date_range = {
      from: @country.daily_rankings.minimum(:snapshot_date),
      to: @country.daily_rankings.maximum(:snapshot_date)
    }

    # # Get coordinates for map
    if @country.geopoint
        geopoint = @country.geopoint.split(',')
        @latitude = geopoint[1]
        @longitude = geopoint[0]
    end
  end

  private

  def set_country
    @country = Country.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to countries_path, alert: "Country not found."
  end
end
