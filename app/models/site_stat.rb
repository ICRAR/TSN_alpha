class SiteStat < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  attr_accessible :change_time, :current_value, :name, :previous_value, :description, :show_in_list, :as => [:admin]
  scope :for_feed, where(:show_in_list => true)
  def self.set_desc(name,desc)
    s = self.get(name)
    if s == nil
      s = self.new
      s.current_value = 0
      s.previous_value = 0
      s.name = name
      s.description = desc
      s.change_time = Time.now
      s.show_in_list = true
      s.save
    else
      s.description = desc
      s.show_in_list = true
      s.change_time = Time.now
      s.save
    end
    s
  end

  def self.get(name)
    self.find_by_name(name)
  end

  def self.set(name,value)
    value = value.to_s
    s = self.get(name)
    if s == nil
      s = self.new
      s.current_value = value
      s.previous_value = value
      s.name = name
      s.change_time = Time.now
      s.save
    else
      s.set(value)
    end
    s
  end
  def set(value)
    value = value.to_s
    if self.value ==  value
      self.touch
    else
      self.previous_value = self.current_value
      self.current_value = value
      self.change_time = Time.now
      self.save
    end
  end


  def dir
    current_value.to_i >= previous_value.to_i ? 'asc' : 'desc'
  end
  def value
    current_value
  end

  def desc
    s = self.description
    if s.include?("%value")
      s = s.sub('%value',number_with_delimiter(current_value.to_i))
    end
    if s.include?("%word_value")
      s = s.sub('%word_value',current_value.to_i.en.numwords)
    end
    if s.include?("%dir")
      if dir == 'asc'
        dir_sub = s.scan(/%dir\((.*),.*\)/).first.first
      else
        dir_sub = s.scan(/%dir\(.*,(.*)\)/).first.first
      end
      s = s.sub(/%dir\(.*,.*\)/,dir_sub)
    end
    if s.include?("%plural")
      p_word = s.scan(/%plural\((.*)\)/).first.first
      s = s.sub(/%plural\(.*\)/,p_word.pluralize(current_value.to_i))
    end

    s
  end


end
