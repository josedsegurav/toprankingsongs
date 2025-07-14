class CreateDailyRankings < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_rankings do |t|
      t.references :track, null: false, foreign_key: true
      t.references :country, null: false, foreign_key: true
      t.date :snapshot_date
      t.integer :daily_rank
      t.integer :popularity

      t.timestamps
    end
  end
end
