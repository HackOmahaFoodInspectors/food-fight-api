class AddRestaurantTable < ActiveRecord::Migration
  def up
    create_table :restaurants do |t|
      t.string :name
      t.string :address
      t.string :photo :nillable => true
      t.string :tip, :nillable => true
    end
  end
  
  def down
    drop_table :restaurants
  end
end