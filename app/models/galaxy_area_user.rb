class GalaxyAreaUser < PogsModel
  # attr_accessible :title, :body
  self.table_name = 'area_user'

  belongs_to :area, class_name: "GalaxyArea", foreign_key: 'area_id'
end