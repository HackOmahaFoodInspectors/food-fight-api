class Restaurant < ActiveRecord::Base
  
  attr_accessor :wins
  attr_accessor :losses
  
  def self.get_opponent
    max_range = Restaurant.count
    row = Random.rand(max_range) + 1
    
    Restaurant.first(:offset => row)
  end
  
  def update_score(decision)
    puts self.inspect
    
    if decision == "winner"
      @wins = 0 if @wins.nil?
      @wins += 1
    else
      @losses = 0 if @losses.nil?
      @losses += 1
    end
    
    self.save  
  end
end