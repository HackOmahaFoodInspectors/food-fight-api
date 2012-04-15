class Restaurant < ActiveRecord::Base
  def self.get_opponent
    max_range = Restaurant.count
    row = Random.rand(max_range) + 1
    
    Restaurant.first(:offset => row)
  end
end