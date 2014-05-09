class TheSkyMap::ShoutBox < TheSkyMap::BaseModel
  attr_accessible :msg
  def self.table_name_prefix
    'theskymap_'
  end
  def ember_name
    'shout_box'
  end
  def ember_names
    'shout_boxes'
  end
end
