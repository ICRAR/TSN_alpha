class GalaxyTag < PogsModel
  # attr_accessible :title, :body
  self.table_name = 'tag'

  has_and_belongs_to_many :galaxies,
                          class_name: "Galaxy",
                          foreign_key: "tag_id",
                          association_foreign_key: "galaxy_id",
                          join_table: "tag_galaxy"

  def self.search_tag(search_string)
    self.where{tag_text =~ "#{search_string}%" }.limit(8)
  end

end