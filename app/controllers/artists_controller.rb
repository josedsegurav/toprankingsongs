class ArtistsController < ApplicationController
    def index
        @artists = Artist.all
        @albums = Artist.
    end
end
