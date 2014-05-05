class PogsTeamMember < BoincPogsModel
  self.inheritance_column = :_type_disabled
  self.table_name = 'team_delta'

  def check_if_first
    PogsTeamMember.where{(userid == my{self.userid})& (timestamp <= my{self.timestamp})}.count == 1
  end
end
