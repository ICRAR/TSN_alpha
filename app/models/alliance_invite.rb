class AllianceInvite < ActiveRecord::Base
  attr_accessible :alliance_id, :email, :invited_by, :invited_on, :redeemed_on, :token, :used, :redeemed_by

  belongs_to :invited_by, :class_name => "Profile", :foreign_key => "invited_by_id"
  belongs_to :redeemed_by, :class_name => "Profile", :foreign_key => "redeemed_by_id"
  belongs_to :alliance

  validates_presence_of :email

  before_create :setup

  def setup
    self.invited_on = Time.now
    self.used = false
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  def self.valid_token?(email, token)
    invites = self.where(:email => email,:used => false)
    check = nil
    invites.each do |invite|
      check = invite if invite.token == token
    end
    if check && User.find_by_email(email)
      return check
    else
      return nil
    end
  end

  def redeem
    user = User.find_by_email(self.email)
    profile = user.profile if user
    if profile
      if profile.alliance_leader
        return false
      else
        profile.leave_alliance(true, "User is redeeming an alliance invite and needs to leave this alliance first") if profile.alliance
        self.used = true
        self.redeemed_on = Time.now
        profile.invited_by = self
        profile.join_alliance(self.alliance, true, 'User is redeeming an alliance invite')
        self.save
      end
    else
      return false
    end
  end

  def reject
    self.used = true
    self.save
  end

end
