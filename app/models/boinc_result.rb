class BoincResult < BoincPogsModel
# attr_accessible :title, :body
  self.inheritance_column = :_type_disabled
  self.table_name = 'result'

  def self.total_pending(boinc_id)
    self.where{(userid == boinc_id) & (server_state == 5) & (outcome == 1) &(validate_state == 0)}.count
  end
  def self.total_in_progress(boinc_id)
    self.where{(userid == boinc_id) & (server_state == 4)}.count
  end
  def self.running_computers_count(boinc_id)
    self.where{(userid == boinc_id) & (server_state == 4)}.count(:hostid, distinct: true,)
  end
  def self.running_computers(boinc_id)
    self.where{(userid == boinc_id) & (server_state == 4)}.group(:hostid)
  end

end