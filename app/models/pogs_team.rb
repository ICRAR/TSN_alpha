class PogsTeam < BoincPogsModel
# attr_accessible :title, :body
  self.inheritance_column = :_type_disabled
  self.table_name = 'team'

  def copy_to_local(local = nil,boinc_stats_item_hash = nil)
    local ||= Alliance.where{pogs_team_id == my{self.id}}.first
    #create local alliance if it doesn't exist
    if local.nil?
      local = Alliance.new
      local.is_boinc = true
      local.invite_only = (self.joinable == 0)
      local.pogs_team_id = self.id
      check_local = Alliance.where{name == my{self.name}}.first #check to see if an alliance already exists with the same name
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
    local.save if local.changed?
    self.update_memberships local, boinc_stats_item_hash

    #update team leader
    #find team leader
    leader_boinc_id = self.userid
    profile = Profile.joins{general_stats_item.boinc_stats_item}.where{boinc_stats_items.boinc_id == leader_boinc_id}.first
    unless profile.nil?
      unless (local.leader_id == profile.id) || !profile.alliance_leader_id.nil?
        local.leader = profile
        profile.join_alliance(local, false, 'Ensure that leader is part of the alliance (Boinc Sync)')
      end
    end
  end

  def update_memberships(alliance = nil,boinc_stats_item_hash = nil)
    #load local alliance
    alliance ||= Alliance.where{pogs_team_id == my{self.id}}.first
    raise ArgumentError.new("alliance error, alliance not found with pogs_team_id == #{self.id}") if alliance.nil?
    max_update_time = PogsTeamMember.where{(teamid == my{self.id})}.maximum(:timestamp)
    pogs_members = PogsTeamMember.where{(teamid == my{self.id}) & (timestamp > my{alliance.pogs_update_time})}
    #group memberships
    all_memberships = pogs_members.group_by {|m| m.userid}

    #update per user
    all_memberships.each do |pogs_id,members|
      #find local user
      profile = nil
      if boinc_stats_item_hash.nil?
        profile = Profile.joins{general_stats_item.boinc_stats_item}.where{boinc_stats_items.boinc_id == pogs_id}.first
      else
        boinc_item = boinc_stats_item_hash[pogs_id]
        profile = boinc_item.general_stats_item.profile unless boinc_item.nil?
      end
      if profile.nil?
        last = nil
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

            profile.leave_alliance(false, "User left the alliance in BOINC change is being sycned to local DB")
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
    alliance.update_column(:pogs_update_time, alliance.max_update_time) unless alliance.pogs_update_time == max_update_time
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
