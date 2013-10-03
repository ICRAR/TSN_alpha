class Activity < ActiveRecord::Base
  belongs_to :profile
  belongs_to :trackable, :polymorphic => true
  attr_accessible :action, :num_profiles, :trackable

  #takes either a single profile or a group as an active relation
  #then creates new rows in the activities table
  #if its a group populates the :num_profiles field and leaves :profile_id nil
  #elsif its a single profile leaves :num_profiles nil and sets profile_id
  def self.track(profiles,action,trackable)
    if profiles.class == Profile
      profiles.activities.create!(:action => action, :trackable => trackable)
    elsif profiles.class == ActiveRecord::Relation
      Activity.create(:action => action, :trackable => trackable, :num_profiles => profiles.count)
    end
  end

  def is_single?
    !self.profile.nil?
  end
end
