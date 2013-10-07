class Activity < ActiveRecord::Base
  belongs_to :profile
  belongs_to :trackable, :polymorphic => true
  attr_accessible :action, :num_profiles, :trackable, :profile_name, :item_name

  #takes either a single profile or a group as an active relation
  #then creates new rows in the activities table
  #if its a group populates the :num_profiles field and leaves :profile_id nil
  #elsif its a single profile leaves :num_profiles nil and sets profile_id
  def self.track(profiles,action,trackable)
    if profiles.class == Profile
      return unless Activity.scale(action,trackable.class.name,'single' )
      profiles.activities.create!(:action => action, :trackable => trackable)
    elsif profiles.class == ActiveRecord::Relation
      if profiles.size < 4
        profiles.each do |profile|
          return unless Activity.scale(action,trackable.class.name,'single' )
          profile.activities.create!(:action => action, :trackable => trackable)
        end
      else
        return unless Activity.scale(action,trackable.class.name,'multi' )
        Activity.create(:action => action, :trackable => trackable, :num_profiles => profiles.count)
      end
    end


  end

  #returns true or false with a random chance bassed on the action performed
  def self.scale(action,trackable_type, single)
    chances = {
      :Trophy => {
          :award => {
            :single => 0.025,
            :multi => 1.0
          }
      },
      :Alliance => {
          :join => 1.0
      }
    }
    chance = chances
    chance = chance[trackable_type.to_sym] if !trackable_type.nil? && !chance[trackable_type.to_sym].nil?
    chance = chance[action.to_sym]  if chance.class == Hash && !action.nil? && !chance[action.to_sym].nil?
    chance = chance[single.to_sym]  if chance.class == Hash && !single.nil? && !chance[single.to_sym].nil?
    chance = 1.0 if chance.class == Hash
    (chance > rand())
  end

  def is_single?
    !self.profile_id.nil?
  end

  before_save :update_names
  def update_names
    if self.is_single?
      self.profile_name = self.profile.name
      self.avatar_url = self.profile.avatar_url(24)
    end
    temp_name = self.trackable.try(:name) if self.trackable.respond_to?(:name)
    temp_name ||= self.trackable.try(:title) if self.trackable.respond_to?(:title)
    temp_name ||= self.trackable_type
    temp_name ||= 'Unknown'
    self.item_name = temp_name
  end
end
