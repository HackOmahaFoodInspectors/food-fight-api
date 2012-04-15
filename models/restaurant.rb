class Restaurant < ActiveRecord::Base
  def self.get_opponent
    max_range = Restaurant.count
    row = Random.rand(max_range) + 1
    
    Restaurant.first(:offset => row)
  end

  def calculated_user_rating
    r = self.user_rating
    if r <= 100
      'FAIR'
    elsif r <= 150
      'STANDARD'
    elsif r <= 200
      'EXCELLENT'
    else
      'SUPERIOR'
    end
  end

  def conflicting_ratings?
    calculated_user_rating != self.rating
  end
end
