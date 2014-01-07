class ProfilesTrophy < ActiveRecord::Base
  belongs_to :profile
  belongs_to :trophy
  attr_accessible :profile_id, :trophy_id, :priority

  #A user should be notifed whenever a they get awarded a new trophy ie a new row in the ProfilesTrophy table.
  has_many :notifications, foreign_key: :notified_object_id, conditions: {notified_object_type: 'ProfilesTrophy'}, dependent: :destroy
  after_commit :create_notification, on: :create
  def create_notification
    trophy.create_notification(profile)
  end
end