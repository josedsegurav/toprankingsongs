class CreateTracks < ActiveRecord::Migration[8.0]
  def change
    create_table :tracks do |t|
      t.string :name
      t.string :spotify_id
      t.integer :duration_ms
      t.decimal :danceability
      t.decimal :energy
      t.integer :key
      t.integer :mode
      t.decimal :tempo
      t.integer :time_signature
      t.references :album, null: false, foreign_key: true
      t.references :primary_artist, null: false, foreign_key: true

      t.timestamps
    end
  end
end
