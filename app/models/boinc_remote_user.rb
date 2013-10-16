class BoincRemoteUser < BoincPogsModel
  attr_accessible :email_addr
  self.table_name = 'user'

  scope :does_not_have_team_delta, where{id.not_in(PogsTeamMember.select(:userid).group(:userid))}
  scope :teamid_no_team_delta, does_not_have_team_delta.where{teamid != 0}

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
    #check for boinc item, if not create
    boinc_item = BoincStatsItem.where(:boinc_id => self.id).first
    if boinc_item.nil?
      #create new item
      boinc_item = BoincStatsItem.new
      boinc_item.boinc_id = self.id
      boinc_item.credit = self.total_credit
      boinc_item.RAC = self.expavg_credit
      boinc_item.save
    end
    #check if the users are already joined if so do nothing
    return true unless boinc_item.general_stats_item_id.nil?

    #else look for corresponding user.
    local_user = User.where{email == my{self.email_addr}}.first

    if local_user.nil?
      #no local user therefore create one
      self.copy_to_local(self.passwd_hash,false)
    else
      #link users
      local_user.profile.general_stats_item.boinc_stats_item = boinc_item
      local_user.profile.general_stats_item.update_credit
    end

  end

  #creates a new user importing data from POGS,
  #if the theSkyNetPassword if false flags that the user has to be authenticated against the POGS system on next login
  def copy_to_local(password, theSkyNetPassword = true)
    name = self.name
    i = nil
    while !User.where{username == name}.first.nil? do
      name =  self.name + '_pogs' + i.to_s
      i ||= 0
      i += 1
    end

    new_user = User.new(
        :email => self.email_addr,
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

    return new_user
  end

end