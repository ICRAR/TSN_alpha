class TheSkyMap::BaseModel < ActiveRecord::Base
  self.abstract_class = true
  def self.table_name_prefix
    'theskymap_'
  end
end
