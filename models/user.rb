class User < ActiveRecord::Base
  def <=>(b)
    a = self
    a_total = a.wins + a.losses
    b_total = b.wins + b.losses
    if a_total == 0
      returned_value = 1
    elsif b_total == 0
      returned_value = -1
    else
      w = (a.wins / a_total)
      l = (b.wins / b_total)
      returned_value = w <=> l
    end
  end
end
