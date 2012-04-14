class AddUserTable < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :name
      t.datetime :created_at
    end
  end
  
  def down
    drop_table :users
  end
end