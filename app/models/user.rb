class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, ,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :admin, :mod
  # attr_accessible :title, :body



  has_one :profile, :dependent => :destroy, :inverse_of => :user
 # before_create :build_profile

  def is_admin?
    return self.admin
  end
  def is_mod?
    return self.mod
  end

end
