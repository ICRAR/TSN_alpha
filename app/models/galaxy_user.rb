class GalaxyUser < PogsModel
  self.table_name = 'galaxy_user'
  belongs_to :galaxies

  def self.profiles
    group(:userid).pluck(:userid)
  end
end