class Comment < ActiveRecord::Base
  attr_accessible :content,:commentable_id, :commentable_type, :commentable,
                  :profile_id, :parent_id,  :as => [:default, :admin]
  attr_accessible :moderated, :moderated_at, :as => [:admin]

  validates_presence_of :content, :commentable_type, :commentable_id, :profile_id

  acts_as_tree dependent: :destroy, order: 'created_at'
  belongs_to :commentable, polymorphic: true, counter_cache: true
  belongs_to :profile

  def self.index_types
    ['news']
  end

  scope :for_show_commentable, includes(:profile => [:user])
  scope :for_show_index, includes(:commentable).where{commentable_type.in Comment.index_types}.
    order{created_at.desc}
  def  self.for_show_profile(find_profile_id)
      scoped.for_show_index.where{profile_id == my{find_profile_id}}
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
end
