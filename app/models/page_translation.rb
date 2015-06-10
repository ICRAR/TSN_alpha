class PageTranslation < ActiveRecord::Base
  validates :title, length: { maximum: 255 }, presence: true
  validates :content, :locale, presence: true

  belongs_to :page
  attr_accessible :locale, :title, :content, :page_attribute, :page_id, as: :admin
  rails_admin do
    include_all_fields
    field :page_id do
      read_only true
    end
    field :content , :text do
      ckeditor true
      ckeditor_location "#{Tsn::Application.config.action_controller.asset_host}#{Tsn::Application.config.assets.prefix}/ckeditor/ckeditor.js"
      if Rails.env.development?
        ckeditor_base_location "http:#{Tsn::Application.config.action_controller.asset_host}#{Tsn::Application.config.assets.prefix}/ckeditor/"
      else
        ckeditor_base_location "https:#{Tsn::Application.config.action_controller.asset_host}#{Tsn::Application.config.assets.prefix}/ckeditor/"
      end    end
  end
end
