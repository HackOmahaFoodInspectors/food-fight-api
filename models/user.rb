class User < ActiveRecord::Base
  
  def update_score(user_result)
    if user_result == 'winner'
      @wins += 1
    else
      @losses += 1
    end
    
    self.save
  end
end
