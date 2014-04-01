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

  scope :include_likes_count, joins{likes.outer}.
        group{id}.
        select("#{self.table_name}.*").select{count(likes.id).as('likes_count')}
  def self.include_liked(profile_id)
      scoped.select{coalesce(find_in_set(profile_id,likes.liker_id),0).as('liked')}
  end

  def self.for_show_commentable(current_user = nil)
    if current_user.nil?
      return scoped.includes(:profile => [:user]).include_likes_count
    else
      return scoped.includes(:profile => [:user]).include_likes_count.include_liked(current_user.profile.id)
    end
  end
  scope :for_show_index, includes(:commentable).where{commentable_type.in Comment.index_types}.
    order{created_at.desc}
  def  self.for_show_profile(find_profile_id)
      scoped.for_show_index.where{profile_id == my{find_profile_id}}
  end

  #socil functions
  acts_as_likeable
  has_many :likes, as: :likeable, class_name: Socialization.like_model.to_s

  def self.notify_users(id)
    Comment.find(id).notify_users
  end
  def notify_users
    #first up notify parent if this is a reply
    notify_parent(profile_id,profile.name)
    #then notify all alliance members if this is a new thread
    notify_alliance if commentable_type == Alliance.to_s && parent_id == nil
    #then notify all challengers if this is a new thread
    notify_challengers if commentable_type == Challenge.to_s && parent_id == nil
  end

  def notify_challengers
    challenge = commentable
    profiles = challenge.profiles.where{id != my{profile_id}}
    subject = "#{profile.name} has started a new thread on a challenge that you are involved in."
    link_challenge = ActionController::Base.helpers.link_to(challenge.name, polymorphic_path(commentable))
    link_commentor = ActionController::Base.helpers.link_to(profile.name, Rails.application.routes.url_helpers.profile_path(profile_id))
    body = "Hey, <br /> #{link_commentor} has started a new thread on the #{link_challenge} challenge page. <br /> Happy Computing! <br />  - theSkyNet"

    aggregation_subject = "%COUNT% new threads have been started on the #{challenge.name} page"
    aggregation_body = "Hey, <br /> %COUNT% new threads have been started on the #{link_challenge} page. <br /> By:"
    aggregation_text = "#{link_commentor} <br />"
    ProfileNotification.notify_all(profiles,subject,body,challenge,true, aggregation_text)
    ProfileNotification.aggrigate_by_class_id(Challenge.to_s,challenge.id,aggregation_subject,aggregation_body)

  end
  def notify_alliance
    alliance = commentable
    profiles = alliance.members.where{id != my{profile_id}}
    subject = "#{profile.name} has started a new thread on your alliance page"
    link_alliance = ActionController::Base.helpers.link_to('alliance page', polymorphic_path(commentable))
    link_commentor = ActionController::Base.helpers.link_to(profile.name, Rails.application.routes.url_helpers.profile_path(profile_id))
    body = "Hey, <br /> #{link_commentor} has started a new thread on your #{link_alliance}. <br /> Happy Computing! <br />  - theSkyNet"

    aggregation_subject = "%COUNT% new threads have been started on your alliance page"
    aggregation_body = "Hey, <br /> %COUNT% new threads have been started on your #{link_alliance}. <br /> By:"
    aggregation_text = "#{link_commentor} <br />"
    ProfileNotification.notify_all(profiles,subject,body,alliance,true, aggregation_text)
    ProfileNotification.aggrigate_by_class_id(Alliance.to_s,alliance.id,aggregation_subject,aggregation_body)
  end
  def notify_parent(base_profile_id,base_profile_name,profiles_notified = [])
    #if the comment has a parent
    unless parent_id.nil?
      pro = parent.profile
      #and that owner of that comment is the same as the current commentor, or has already been notified about this comment
      unless base_profile_id ==  pro.id || profiles_notified.include?(pro.id)
        #notify them
        subject = "#{base_profile_name} has replied to your comment on, #{commentable_name}"
        link_commentable = ActionController::Base.helpers.link_to(commentable_name, polymorphic_path(commentable))
        link_commentor = ActionController::Base.helpers.link_to(base_profile_name, Rails.application.routes.url_helpers.profile_path(base_profile_id))
        body = "Hey #{pro.name}, <br /> #{link_commentor} replied to your comment on #{link_commentable}. <br /> Happy Computing! <br />  - theSkyNet"

        aggregation_subject = "Your comment on #{link_commentable} has been replied to %COUNT% times"
        aggregation_body = "Hey #{pro.name}, <br /> Your comment on #{commentable_name} has been replied to %COUNT% times. <br /> By:"
        aggregation_text = "#{link_commentor} <br />"
        ProfileNotification.notify_with_aggrigation(pro,subject,body,aggregation_subject,aggregation_body,'class_id',self.commentable, aggregation_text)
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
