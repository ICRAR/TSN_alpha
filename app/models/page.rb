class Page < ActiveRecord::Base
  translates :content, :title, :versioning => true, :fallbacks_for_empty_translations => true
  #translates :content, :title, :fallbacks_for_empty_translations => true
  validates :page_translations, presence: :true
  has_many :page_translations, dependent: :destroy, :autosave => true
  accepts_nested_attributes_for :page_translations, allow_destroy: true
  attr_accessible :page_translations_attributes, :as => :admin, :allow_destroy => true

  attr_accessible :slug, :parent_id, :sub_page_ids, :science_portal_id, :preview, :sort_order, as: :admin
  validates_presence_of :slug
  has_many :sub_pages, :class_name => "Page", :foreign_key => "parent_id", :inverse_of => :parent
  belongs_to :parent, :class_name => "Page", :inverse_of => :sub_pages

  #optional for science portals
  belongs_to :science_portal

  scope :for_links, where{preview == false}.order(:sort_order)

  def to_param
    slug
  end

  #fix for using papertrail with globalize3
  def initialize_copy(source)
    obj = super(source)
    obj.tap { |o| o.send(:remove_instance_variable, :@globalize) } rescue obj
  end

  rails_admin do
    include_all_fields
    field :parent do
      searchable true
    end
    field :sub_pages do
      orderable true
    end
  end
end
