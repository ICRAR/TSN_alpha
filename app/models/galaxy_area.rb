class GalaxyArea < PogsModel
  # attr_accessible :title, :body
  self.table_name = 'area'

  def self.areas(galaxy_id, user_id)
    if user_id == 'all'
      where(:galaxy_id => galaxy_id)
      .order(:top_x,:top_y)
    else
      joins("INNER JOIN area_user ON area.area_id = area_user.area_id")
      .where(:area_user => {:userid => user_id}, :galaxy_id => galaxy_id)
      .order(:top_x,:top_y)
    end
  end
end