class Page < ActiveRecord::Base
  attr_accessible :content, :title, :slug, :parent_id, :sub_page_ids, as: :admin
  validates_presence_of :content, :title, :slug
  has_many :sub_pages, :class_name => "Page", :foreign_key => "parent_id", :inverse_of => :parent
  belongs_to :parent, :class_name => "Page", :inverse_of => :sub_pages

  def to_param
    slug
  end

  rails_admin do
      field :title
      field :slug
      field :parent do
        searchable true
      end
      field :sub_pages do
        orderable true
      end
      field :content, :text do
        ckeditor true
    end
  end
end
