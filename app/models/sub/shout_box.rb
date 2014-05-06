class Sub::ShoutBox < ActiveRecord::Base
  attr_accessible :msg
  def ember_name
    'shout_box'
  end
  def ember_names
    'shout_boxes'
  end
end
