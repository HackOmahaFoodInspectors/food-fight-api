class AddUserRatings < ActiveRecord::Migration
  class Restaurant < ActiveRecord::Base
  end
  def change
    add_column :restaurants, :user_rating, :integer
    Restaurant.reset_column_information
    conversion = {
      "FAIR" => 100,
      "STANDARD" => 150,
      "EXCELLENT" => 200,
      "SUPERIOR" => 250
    }
    Restaurant.all.each do |r|
      rating = r.rating
      r.update_attributes!(:user_rating => conversion[rating])
    end

  end
end
