class SiteStat < ActiveRecord::Base
  attr_accessible :change_time, :current_value, :name, :previous_value

  def self.get(name)
    self.find_by_name(name)
  end

  def self.set(name,value)
    s = self.get(name)
    if s == nil
      s = self.new
      s.current_value = value
      s.previous_value = value
      s.name = name
      s.change_time = Time.now
      s.save
    else
      if s.value ==  value
        s.touch
      else
        s.previous_value = s.current_value
        s.current_value = value
        s.change_time = Time.now
        s.save
      end
    end
    s
  end

  def dir
    current_value >= previous_value ? 'asc' : 'desc'
  end
  def value
    current_value
  end
end
