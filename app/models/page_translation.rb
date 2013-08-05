class PageTranslation < ActiveRecord::Base
  validates :title, length: { maximum: 255 }, presence: true
  validates :content, :locale, presence: true

  belongs_to :page
  attr_accessible :locale, :title, :content, :page_attribute, as: :admin
  rails_admin do
    include_all_fields
    field :content , :text do
      ckeditor true
    end
  end
end
