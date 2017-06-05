class BoincRemoteUser < BoincPogsModel
  attr_accessible :email_addr
  self.table_name = 'user'

  scope :does_not_have_team_delta, where{id.not_in(PogsTeamMember.select(:userid).group(:userid))}
  scope :teamid_no_team_delta, does_not_have_team_delta.where{teamid != 0}

  has_one :profile, class_name: BoincProfile, foreign_key: 'userid'

  # Creates a boinc stats item if one doesn't exist for this boinc ID.
  # Returns the stats item associated with this boinc ID,
  def check_stats_item
    # Find a local boinc stats item. Can find via the boinc_id
    boinc_item = BoincStatsItem.where(:boinc_id => self.id).first
    if boinc_item.nil?
      # Doesn't exist, so we create it
      puts "Creating BoincStatsItem for user #{self.email_addr}"
      boinc_item = BoincStatsItem.new
      boinc_item.boinc_id = self.id
      boinc_item.credit = self.total_credit
      boinc_item.RAC = self.expavg_credit
      boinc_item.save
    else
      puts "Boinc stats item already exists for #{self.email_addr}"
    end

    boinc_item
  end

  # Returns a local user with the same email address as the remote user, or nil of no local users with that email exist.
  def find_local_by_email
    # Look for a local user by their email address
    email_encoded = self.email_addr
    begin
      email_check = email_encoded.dup
      email_check.force_encoding("UTF-8").encode("cp1252")
    rescue ##ToDO MAKE ME BETTER PLEASE####
      email_encoded = URI.encode(email_encoded)
    end

    local_user = User.where{email == my{email_encoded}}.first
    if local_user.nil?
      local_user = User.where{boinc_id == my{self.id}}.first
    end

    local_user
  end

  # Patches the links between a local user and their boinc item.
  def patch_links(local_user, boinc_item)
    if local_user.profile.general_stats_item.boinc_stats_item.nil?
      # If there is a local user, link their data together
      local_user.profile.general_stats_item.boinc_stats_item = boinc_item
      local_user.profile.general_stats_item.update_credit
      email_addr
      true
    end
    false
  end

  def email_addr
    self[:email_addr].tr(" ", "_")
  end

  def self.auth(login, password)
    user = self.where{(email_addr == login)}.first
    return false if user.nil?
    pwd_hash = Digest::MD5.hexdigest(password+login.downcase)
    return pwd_hash == user.passwd_hash ? user : false
  end

  #looks for a local versions of the user, if it can't find one it will create it
  def check_local
    local_user = User.where("boinc_id = #{self.id}").first

    # Get or create a boinc stats item for this boinc id
    boinc_item = check_stats_item

    if local_user != nil
      # A user with this Boinc ID already exists locally, try to patch up any local links
      if patch_links(local_user, boinc_item)
        puts "User #{self.email_addr} with bad stats item patched"
      end

      return
    end

    # No local user by boinc ID

    # See if we can instead find them by email
    local_user = find_local_by_email

    # If there's no local user by email or boinc id, create them
    if local_user.nil?
      puts "Copying user #{self.email_addr}to local..."
      copy_to_local(self.passwd_hash,false)
    elsif patch_links(local_user, boinc_item)
      # Found a user with an email address matching, but no boinc id matching.
      puts "Linking user #{self.email_addr} with #{self.id}"
      local_user.boinc_id = self.id
    else
      puts 'User is ok'
    end

  end

  #creates a new user importing data from POGS,
  #if the theSkyNetPassword if false flags that the user has to be authenticated against the POGS system on next login
  def copy_to_local(password, theSkyNetPassword = true)
    name = self.name
    i = nil

    puts 'Encoding email'
    email_encoded = self.email_addr
    begin
      email_check = email_encoded.dup
      email_check.force_encoding("UTF-8").encode("cp1252")
    rescue ##ToDO MAKE ME BETTER PLEASE####
      email_encoded = URI.encode(email_encoded)
    end

    puts 'Encoding name'
    begin
      name_check = name.dup
      name_check.force_encoding("UTF-8").encode("cp1252")
    rescue ##ToDO MAKE ME BETTER PLEASE####
      name = 'unknown_name'
    end
    base_name = name

    puts 'Working out POGS user name...'
    while !User.where{username == name}.first.nil? do
      name =  base_name + '_pogs' + i.to_s
      i ||= 0
      i += 1
    end

    puts 'Making new user...'
    new_user = User.new(
        :email => email_encoded,
        :username => name,
        :password => 'password',
        :password_confirmation => 'password',
    )
    #puts new_user.to_json
    new_user.skip_confirmation!
    new_user.encrypted_password = 'password'
    new_user.boinc_id = self.id  unless theSkyNetPassword
    new_user.confirmed_at = Time.at(self.create_time)
    new_user.joined_at = Time.at(self.create_time)
    if new_user.save
      profile = new_user.profile
      profile.nickname = self.name
      profile.use_full_name = false
      profile.country = self[:country]
      profile.new_profile_step= 2
      profile.description = self.profile.description unless self.profile.nil?
      profile.save
    end
    #puts new_user.to_json
    #look for boinc_stats_item
    boinc_item = BoincStatsItem.where(:boinc_id => self.id).first
    if boinc_item.nil?
      #create new item
      boinc_item = BoincStatsItem.new
      boinc_item.boinc_id = self.id
      boinc_item.credit = self.total_credit
      boinc_item.RAC = self.expavg_credit
      boinc_item.save
    end
    unless boinc_item.nil?
      new_user.profile.general_stats_item.boinc_stats_item = boinc_item
      new_user.profile.general_stats_item.update_credit
    end

    puts 'User complete'
    return new_user
  end

  ###FUNCTIONS FOR WEBRPC Calls to boinc server
  require 'httparty'
  include HTTParty
  format :xml
  base_uri APP_CONFIG['boinc_url']
  def self.join_team(boinc_id,team_id)
    remote_user = BoincRemoteUser.find boinc_id
    remote_user.web_rpc_update  teamid: team_id
  end
  def self.leave_team(boinc_id)
    remote_user = BoincRemoteUser.find boinc_id
    remote_user.web_rpc_update  teamid: 0
  end
  def web_rpc_update(updates)
    updates.select!{|k,v| [:teamid].include? k}
    updates.merge!({account_key: self.authenticator})
    self.class.get('/am_set_info.php',query: updates)
  end
  def rpc_test(updates)
    updates.merge!({account_key: self.authenticator})
    self.class.get('/am_get_info.php',query: updates)
  end

end