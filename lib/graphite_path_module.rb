module GraphitePathModule
  def self.path_for_stats (id)
    GraphitePathModule::path(id,'.')
  end
  def self.path_for_file(id)
    GraphitePathModule::path(id,'/')
  end
  def self.path(id,join)
    ("%09d" % id).scan(/\d{3}/).join(join)
  end
end