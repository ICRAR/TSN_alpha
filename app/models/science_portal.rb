class SciencePortal < ActiveRecord::Base
  attr_accessible :name, :public, :desc, :member_ids, :leader_ids, as: :admin
  has_and_belongs_to_many :members,
                          class_name: "Profile",
                          association_foreign_key: "member_id",
                          foreign_key: "science_portal_id",
                          join_table: "members_science_portals"
  has_and_belongs_to_many :leaders,
                          class_name: "Profile",
                          association_foreign_key: "leader_id",
                          foreign_key: "science_portal_id",
                          join_table: "leaders_science_portals"
  has_many :science_links
  accepts_nested_attributes_for :science_links, :allow_destroy => true
  attr_accessible :science_links_attributes, :as => :admin, :allow_destroy => true

  #optional custom pages
  has_many :pages
  accepts_nested_attributes_for :pages, :allow_destroy => true
  attr_accessible :pages_attributes, :as => :admin, :allow_destroy => true

  def is_leader(profile_id)
    self.leader_ids.include?(profile_id)
  end

  def check_access(profile_id)
    public? || self.is_leader(profile_id) || self.member_ids.include?(profile_id)
  end

  def public?
    self.public == true
  end
  def private?
    !self.public?
  end

  rails_admin do
    include_all_fields
    field :name
    field :public
    field :members do
      inverse_of :members_science_portals
      # configuration here
    end
    field :leaders do
      inverse_of :leaders_science_portals
      # configuration here
    end
    field :science_links do
      # configuration here
      #nested_form true
    end
    field :desc, :text do
      ckeditor true
    end
  end

end
