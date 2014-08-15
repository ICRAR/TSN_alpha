class TheSkyMap::BaseModel < ActiveRecord::Base
  self.abstract_class = true
  def self.table_name_prefix
    'the_sky_map_'
  end
end
