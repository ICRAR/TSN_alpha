class Comment < ActiveRecord::Base
  attr_accessible :content,:commentable_id, :commentable_type, :commentable,
                  :profile_id, :parent_id,  :as => [:default, :admin]
  attr_accessible :moderated, :moderated_at, :as => [:admin]

  validates_presence_of :content, :commentable_type, :commentable_id, :profile_id

  acts_as_tree dependent: :destroy, order: 'created_at'
  belongs_to :commentable, polymorphic: true, counter_cache: true
  belongs_to :profile

  scope :for_show_commentable, includes(:profile => [:user])
  scope :for_show_profile, includes(:commentable)
end
