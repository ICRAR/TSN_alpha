class GalaxyArea < PogsModel
  # attr_accessible :title, :body
  self.table_name = 'area'

  has_many :area_user, class_name: "GalaxyAreaUser", foreign_key: 'area_id'
  belongs_to :galaxy

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

  #returns an array of boinc IDS with more than count galaxies
  def self.userid_by_galaxy_count(count)
    joins{area_user}.select{area_user.userid.as(boinc_id)}
    .group{area_user.userid}
    .having("COUNT(DISTINCT galaxy_id) >= ?",count )
  end
end