class CreateCountries < ActiveRecord::Migration[8.0]
  def change
    create_table :countries do |t|
      t.string :iso_code
      t.string :name
      t.string :geopoint

      t.timestamps
    end
  end
end
