class AddRestaurantTable < ActiveRecord::Migration
  def up
    create_table :restaurants do |t|
      t.string :name
      t.string :address
      t.string :rating
      t.datetime :inspection_date
      t.integer :latitude
      t.integer :longitude
      t.string :photo
      t.string :tip
    end
  end
  
  def down
    drop_table :restaurants
  end
end