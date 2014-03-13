class Comment < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  attr_accessible :content,:commentable_id, :commentable_type, :commentable,
                  :profile_id, :parent_id,  :as => [:default, :admin]
  attr_accessible :moderated, :moderated_at, :as => [:admin]

  has_many :notifications, foreign_key: :notified_object_id, conditions: {notified_object_type: 'Comment'}, dependent: :destroy

  validates_presence_of :content, :commentable_type, :commentable_id, :profile_id

  acts_as_tree dependent: :destroy, order: 'created_at'
  belongs_to :commentable, polymorphic: true, counter_cache: true
  belongs_to :profile

  def self.index_types
    ['news', 'challenge', 'trophy']
  end

  scope :for_show_commentable, includes(:profile => [:user])
  scope :for_show_index, includes(:commentable).where{commentable_type.in Comment.index_types}.
    order{created_at.desc}
  def  self.for_show_profile(find_profile_id)
      scoped.for_show_index.where{profile_id == my{find_profile_id}}
  end


  def self.notify_users(id)
    Comment.find(id).notify_users
  end
  def notify_users
    #first up notify parent if this is a reply
    notify_parent(profile_id,profile.name)
  end
  def notify_parent(base_profile_id,base_profile_name,profiles_notified = [])
    #if the comment has a parent
    unless parent_id.nil?
      pro = parent.profile
      #and that owner of that comment is the same as the current commentor, or has already been notified about this comment
      unless base_profile_id ==  pro || profiles_notified.include?(pro.id)
        #notify them
        subject = "#{base_profile_name} has replied to your comment on, #{commentable_name}"
        link_commentable = ActionController::Base.helpers.link_to(commentable_name, polymorphic_path(commentable))
        body = "Hey #{pro.name}, \n #{base_profile_name} replied to your comment on #{link_commentable}. \n Happy Computing! \n  - theSkyNet"
        pro.notify(subject, body, self)
        profiles_notified << pro.id
      end
      #then notify next level of parents

      parent.notify_parent(base_profile_id,base_profile_name,profiles_notified)
    end
  end

  def commentable_name
    c = commentable
    if c.respond_to? :name
      out = c.name
    elsif c.respond_to? :title
      out = c.title
    else
      out = ''
    end
    out
  end

  def test
    #https://github.com/yuku-t/jquery-textcomplete
    t.gsub( /@(\w+)/ ) do |un|
      u = User.find_by_username(un.gsub('@', ''))
      if u.nil?
        un
      else
        link_to(un,Rails.application.routes.url_helpers.profile_path(u.profile))
      end
    end
  end
end
