class PogsTeam < BoincPogsModel
# attr_accessible :title, :body
  self.inheritance_column = :_type_disabled
  self.table_name = 'team'

  def copy_to_local
    local = Alliance.where{pogs_team_id == my{self.id}}.first
    #create local alliance if it doesn't exist
    if local.nil?
      local = Alliance.new
      local.is_boinc = true
      local.invite_only = true
      local.pogs_team_id = self.id
      local.name = self.name + " (POGS)"
      local.desc = self.description
      local.credit = 0
      local.ranking = nil
      local.pogs_update_time = 0
      local.save
      local.created_at = Time.at(self.create_time)
      local.save
    end

    #update local alliance
    unless local.desc == self.description
      local.desc = self.description
      local.save
    end

    self.update_memberships

    #update team leader
    #find team leader
    leader_boinc_id = self.userid
    leader_boinc_item = BoincStatsItem.where{boinc_id == my{leader_boinc_id}}.first
    unless leader_boinc_item.try(:general_stats_item).nil?
      profile = leader_boinc_item.general_stats_item.profile
      local.leader = profile unless (local.leader_id == profile.id) || !profile.alliance_leader_id.nil?
    end
  end

  def update_memberships
    #load local alliance
    alliance = Alliance.where{pogs_team_id == my{self.id}}.first
    pogs_members = PogsTeamMember.where{(teamid == my{self.id}) & (timestamp > my{alliance.pogs_update_time})}
    #group memberships
    all_memberships = pogs_members.group_by {|m| m.userid}

    #update per user
    all_memberships.each do |pogs_id,members|
      #find local user
      boinc_item = BoincStatsItem.where{boinc_id == my{pogs_id}}.first
      if !boinc_item.nil? && !boinc_item.general_stats_item.nil?
        profile = boinc_item.general_stats_item.profile
        last = nil
        if !profile.nil?
          #if local user is found
          #iterate through each membership to be updated
          members.each do |m|
            #if this is joining a team
            if m.joining == 1
              #create new alliance member
              member = AllianceMembers.new
              member.alliance_id = alliance.id
              member.profile_id = profile.id
              member.join_date = Time.at(m.timestamp)
              member.start_credit = m.total_credit
              #if timestamp is within 1 day and the users local credit is higher than POGS credit use local credit
              if m.timestamp > 1.day.ago.to_i &&  profile.general_stats_item.total_credit.to_i > m.total_credit
                member.start_credit = profile.general_stats_item.total_credit
              end
              member.start_credit ||= 0
              member.leave_credit = profile.general_stats_item.total_credit

              member.leave_credit ||= 0
              member.leave_date = nil
              member.save
            else
              #or leaving a team
              #update alliance item
              member = AllianceMembers.where{(alliance_id == my{alliance.id}) &
                (profile_id == my{profile.id}) &
                (leave_date == nil)
              }.first
              if member.nil? && m.total_credit.to_i == 0
                #can't find corresponding join entry
                #if total credit is 0 ignore, strange boinc condition
              else
                if member.nil? && m.total_credit.to_i > 0
                  #Team delta is a new feature to BOINC we must assume this member joined before that time
                  #So create them a new member item starting with 0 credit
                  member = AllianceMembers.new
                  member.alliance_id = alliance.id
                  member.profile_id = profile.id
                  member.join_date = Time.at(m.timestamp)
                  member.start_credit =0
                end
                member.leave_date = Time.at(m.timestamp)
                member.leave_credit = m.total_credit
                #if timestamp is within 1 day and the users local credit is higher than POGS credit use local credit
                if m.timestamp > 1.day.ago.to_i &&  profile.general_stats_item.total_credit.to_i > m.total_credit
                  member.leave_credit = profile.general_stats_item.total_credit
                end
                member.leave_credit ||= 0

                member.save

                #if this was the users current alliance make sure they leave.
                if profile.alliance.try(:id) == alliance.id
                  profile.alliance = nil
                  profile.save
                end
              end

            end
          end
          #finnally if the last action was to join an alliance make sure that is reflected in theSkyNet
          if members.last.try(:joining) == 1
            if profile.alliance.nil?
              profile.alliance = alliance
              profile.save
            else
              profile.leave_alliance
              profile.alliance = alliance
              profile.save
            end
          end
        end
      end
    end
    alliance.pogs_update_time = Time.now.to_i
    alliance.save
  end
end
