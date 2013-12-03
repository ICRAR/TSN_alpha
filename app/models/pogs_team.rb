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
      local.invite_only = (self.joinable == 0)
      local.pogs_team_id = self.id
      check_local = Alliance.where{name == self.name}.first #check to see if an alliance already exists with the same name
      if check_local.nil?
        local.name = self.name
      else
        local.name = self.name + " (POGS)"
      end
      local.desc = self.description
      local.credit = 0
      local.ranking = nil
      local.pogs_update_time = 0
      local.save
      local.created_at = Time.at(self.create_time)
    end

    #update local alliance
    local.desc = self.description
    local.invite_only = (self.joinable == 0)
    local.save
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
              AllianceMembers.join_alliance_from_boinc(profile,alliance,m)
            else
              #or leaving a team
              AllianceMembers.leave_alliance_from_boinc(profile,alliance,m)
            end
          end
          #finnally make sure last action is reflected in theSkyNet
          if members.last.try(:joining) == 1
            if profile.alliance.nil?
              profile.alliance = alliance
              profile.save
              #update notifications
              AllianceMembers.create_notification_join(profile.alliance_items.last.id)
            elsif profile.alliance_id != alliance.id
              #email user notifying them that they have been automatically removed from an alliance
              if profile.alliance.pogs_team_id.nil? || profile.alliance.pogs_team_id == 0
                UserMailer.alliance_sync_removal(profile, profile.alliance, alliance).deliver
              end

              profile.leave_alliance(false)
              profile.alliance = alliance
              profile.save
              #update notifications
              AllianceMembers.create_notification_join(profile.alliance_items.last.id)
            end

          elsif members.last.try(:joining) == 0
            #if this was the users current alliance make sure they leave.
            if profile.alliance_id == alliance.id
              profile.alliance = nil
              profile.save
              #update notifications
              AllianceMembers.create_notification_leave(profile.alliance_items.last.id)
            end
          end
        end
      end
    end
    alliance.pogs_update_time = Time.now.to_i
    alliance.save
  end

  ###FUNCTIONS FOR WEBRPC Calls to boinc server
  require 'httparty'
  include HTTParty
  format :xml
  base_uri APP_CONFIG['boinc_url']
  def self.create_new(alliance_id, invite_only)
    alliance = Alliance.find alliance_id
    name = alliance.name
    raise "Alliance name is already taken" unless PogsTeam.find_by_name(name).nil?

    raise "Alliance isn't marked as a POGS team" unless alliance.is_boinc?
    raise "POGS team has already been created" if alliance.pogs_team_id > 0

    opts = {}

    boinc_item = alliance.leader.general_stats_item.boinc_stats_item
    raise "leader must be a boinc member" if boinc_item.nil?
    boinc_user = BoincRemoteUser.find boinc_item.boinc_id
    opts[:account_key] = boinc_user.authenticator
    opts[:name] = name
    opts[:name_html] = name
    opts[:description] = alliance.desc unless alliance.desc.nil?
    opts[:description] ||= ''
    opts[:country ] = alliance.country unless alliance.country.nil?
    opts[:country ] ||= 'None'
    opts[:type] = 1 #boinc team type "None" as feature is not yet implemented in TSN
    opts[:url] = Rails.application.routes.url_helpers.alliance_url alliance, host: APP_CONFIG['site_host']


    response = PogsTeam.get('/create_team.php',query: opts)
    team_id =    response["create_team_reply"]["team_id"].to_i
    alliance.pogs_team_id = team_id
    alliance.pogs_update_time = Time.now
    alliance.invite_only = invite_only
    alliance.save
  end
end
