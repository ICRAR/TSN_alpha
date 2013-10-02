# in models/admin_ability.rb
class AdminAbility
  include CanCan::Ability
  def initialize(user)
    #mod users can edit pages and science portals that the are a leader on
    if user && user.is_mod?
      can :manage, Page
      can :manage, SciencePortal
      can :access, :rails_admin
      can :dashboard
    end
    if user && user.admin?
      can :access, :rails_admin
      can :manage, :all
      can :dashboard
    end
  end
end