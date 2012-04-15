class User < ActiveRecord::Base
  
  attr_accessor :wins
  attr_accessor :losses

  def update_score(user_result)
    puts self.inspect
    if user_result == 'winner'
      @wins += 1
    else
      @losses += 1
    end
    
    self.save
  end
end
