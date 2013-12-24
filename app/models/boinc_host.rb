class BoincHost < BoincPogsModel
# attr_accessible :title, :body
  self.inheritance_column = :_type_disabled
  self.table_name = 'host'

  def self.running_computers(boinc_id)
    host_ids = BoincResult.running_computers(boinc_id).map(&:hostid)
    self.where{(id.in host_ids)}
  end

end
