class AddRestaurantResultTracking < ActiveRecord::Migration
  def change
    add_column :restaurants, :wins, :integer, :default => 0
    add_column :restaurants, :losses, :integer, :default => 0
  end
end