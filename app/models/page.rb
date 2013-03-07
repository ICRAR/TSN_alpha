class Page < ActiveRecord::Base
  attr_accessible :content, :title, :slug
  validates_presence_of :content, :title, :slug
  def to_param
    slug
  end

  rails_admin do
      field :title
      field :slug
      field :content, :text do
        ckeditor true
    end
  end
end
