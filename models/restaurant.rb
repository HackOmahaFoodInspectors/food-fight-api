class Restaurant < ActiveRecord::Base

  def self.get_opponent
    max_range = Restaurant.count
    row = Random.rand(max_range) + 1
    
    Restaurant.first(:offset => row)
  end
  
  def update_score(decision)
    if decision == "winner"
      self.wins += 1
    else
      self.losses += 1
    end
    
    self.save  
  end
end