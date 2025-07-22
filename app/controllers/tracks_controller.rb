class TracksController < ApplicationController
    def index
  # Base query without custom select for pagination compatibility
  @tracks = Track.includes(:artist, :album, daily_rankings: :country)
  @tracks_artistcount = @tracks.joins(:album).select('albums.primary_artist_id').distinct.count
  @tracks_albumcount = @tracks.joins(:album).select(:album_id).distinct.count

  if params[:search].present?
    search_term = "%#{params[:search]}%"
    @tracks = @tracks.joins(:artist, :album)
                     .where("tracks.name LIKE ? OR artists.name LIKE ? OR albums.title LIKE ?",
                            search_term, search_term, search_term)

    @tracks_artistcount = @tracks.joins(:album).select('albums.primary_artist_id').distinct.count
    @tracks_albumcount = @tracks.joins(:album).select(:album_id).distinct.count
  end

  # Order by country count (without custom select for now)
  @tracks = @tracks.joins(:daily_rankings)
                   .group('tracks.id')
                   .order(Arel.sql('COUNT(DISTINCT daily_rankings.country_id) DESC'))

  per_page = [params[:per_page].to_i, 100].min
  per_page = 15 if per_page <= 0
  @tracks = @tracks.page(params[:page]).per(per_page)

  # Now get the country counts for the paginated tracks
  track_ids = @tracks.pluck(:id)
  @track_country_counts = Track.joins(:daily_rankings)
                              .where(id: track_ids)
                              .group('tracks.id')
                              .count('DISTINCT daily_rankings.country_id')

  # Include associations for the paginated results
#   @tracks = @tracks.includes(:artist, :album, daily_rankings: :country)
end

    def show
        @track = Track.includes(:artist, :album, daily_rankings: :country).find(params[:id])
        @track_country_counts = @track.daily_rankings
                                  .joins(:country)
                                  .group('countries.name')
                                  .count


        keys = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        modes = ["Minor", "Mayor"]
        @track_key = keys[@track.key]
        @track_keymode = modes[@track.mode]
    end
end
