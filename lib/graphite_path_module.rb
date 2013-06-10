module GraphitePathModule
  def self.path_for_stats (id)
    GraphitePathModule::path(id,'.')
  end
  def self.path_for_file(id)
    GraphitePathModule::path(id,'/')
  end
  def self.path(id,join)
    output = ''
    while id/1000 != 0
      output = (id%1000).to_s + output
      output = '0' + output if id%1000/10 == 0
      output = '0' + output if id%1000/100 == 0
      output = join + output
      id = id/1000
    end
    output = (id%1000).to_s + output
  end
end