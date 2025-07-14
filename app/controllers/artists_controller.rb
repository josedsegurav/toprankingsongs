class ArtistsController < ApplicationController
    def index
        @artists = Artist.includes(:albums, :tracks).all
        @artists = @artists.page(params[:page]).per(20)

    end
end
