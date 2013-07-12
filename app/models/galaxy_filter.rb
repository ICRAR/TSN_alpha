class GalaxyFilter < PogsModel
  self.table_name = 'filter'

  def self.labels()
    filters = self.all
    f_map = {}
    filters.each do |filter|
      f_map[filter.id] = filter.label
    end
    f_map
  end
end