class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, ,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :async,
         :authentication_keys => [:login]
  alias_method :devise_valid_password?, :valid_password?
  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :as => [:default, :admin]
  attr_accessible :admin, :mod, as: :admin
  # attr_accessible :title, :body

  #fix to allow login by either email or username/
  attr_accessor :login
  attr_accessible :login

  validates :username, :uniqueness => true
  #validates :username, :email, :password, :password_confirmation, :presence => true
  validates :email, :uniqueness => true

  has_one :profile, :dependent => :destroy, :inverse_of => :user
  before_create :build_profile

  before_invitation_accepted :check_alliance_invite


  def check_alliance_invite
    invite = AllianceInvite.valid_token?(self.email, self.invitation_token)
    invite.redeem if invite != nil
  end

  def is_admin?
    return self.admin
  end
  def is_mod?
    return self.mod
  end

  # app/models/user.rb

  def my_destroy
    self.profile.general_stats_item.bonus_credits.destroy
    self.profile.general_stats_item.destroy
    self.profile.profiles_trophies.delete_all
    self.profile.delete
    self.delete
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def username_forum
    username ? username : email
  end
### This is the correct method you override with the code above
### def self.find_for_database_authentication(warden_conditions)
### end


  #allows password recovery with data from old site or POGS site

  def valid_password?(password)
    begin
      super(password)
    rescue BCrypt::Errors::InvalidHash
      #if User is flag to auth with POGS if not try with old theSkyNet System
      if boinc_id.nil?
        #auth if old theSkyNet
        return false unless
            Digest::SHA256.hexdigest(self.old_site_password_salt+Digest::SHA256.hexdigest(password)) == self.encrypted_password
        logger.info "User #{email} is using the old password hashing method, updating attribute."
        self.profile.new_profile_step= 2
        self.profile.save
        #look for a boinc account with the same email, pasword.
        boinc = BoincStatsItem.find_by_boinc_auth(email,password)
        if boinc.new_record?
          #Could not find account so do nothing for this step
        else
          #found account so add it
          self.profile.general_stats_item.boinc_stats_item = boinc
          self.profile.save
        end
        self.password = password
        self.password_confirmation = password
        self.save
        true
      else
        #auth with POGS
        #lookup user in boincDB
        boinc_user = BoincRemoteUser.auth(email ,password)
        # check if their vaild
        if boinc_user == false
          #failed to authenticate against the boincdb
          return false
        else
          self.profile.new_profile_step= 2
          self.profile.save
          self.password = password
          self.password_confirmation = password
          self.save
          true
        end
      end
    end
  end



end
