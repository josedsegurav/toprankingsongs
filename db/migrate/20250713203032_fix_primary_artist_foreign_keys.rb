class FixPrimaryArtistForeignKeys < ActiveRecord::Migration[8.0]
  def change
    # Remove the incorrect foreign key references
    remove_foreign_key :albums, :primary_artists
    remove_foreign_key :tracks, :primary_artists

    # Add the correct foreign key references to the artists table
    add_foreign_key :albums, :artists, column: :primary_artist_id
    add_foreign_key :tracks, :artists, column: :primary_artist_id
  end
end
