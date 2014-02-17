class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

   #note the user object is managed within devise
   user ||= User.new # guest user

   #defult permissions for all users
   can :run, NereusStatsItem
   can :read, :all
   can :search, :all
   can :promote, Trophy
   can :trophies, Profile
   cannot :join, Alliance
   cannot :leave, Alliance
   can :image, Galaxy
   can :send_report, Galaxy
   cannot :read, User
   can :alliance_history, Profile

  if user.id #user is not a quest user
    can :new, NereusStatsItem
    can :create, Alliance
    can :manage, Alliance, :id => user.profile.alliance_leader_id
    can :manage, Profile, :user_id => user.id
    can :manage, User, :id => user.id
    can :join, Alliance
    can :leave, Alliance
    can :dismiss, News
    can :send_cert, NereusStatsItem
    can :create, Comment
    can [:update, :destroy], Comment do |comment|
      comment.created_at >= 60.minutes.ago && comment.profile_id == user.profile.id
    end
  end
   #admin users can do everything :)
   if user.is_admin?
      can :manage, :all
   end
end
end
