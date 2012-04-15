class User < ActiveRecord::Base
  
  def update_score(user_result)
    if user_result == 'winner'
      self.wins += 1
    else
      self.losses += 1
    end
    
    self.save
  end
end