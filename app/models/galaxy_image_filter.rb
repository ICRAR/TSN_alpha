class GalaxyImageFilter < PogsModel
  self.table_name = 'image_filters_used'

  def self.label(galaxy_id, colour)
    f_map = GalaxyFilter.labels
    filters_used = self.where(:galaxy_id => galaxy_id,:image_number => colour).first
    "#{f_map[filters_used.filter_id_red]}, #{f_map[filters_used.filter_id_green]}, #{f_map[filters_used.filter_id_blue]}"
  end
end