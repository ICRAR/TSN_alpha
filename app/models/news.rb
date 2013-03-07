class News < ActiveRecord::Base
  attr_accessible :long, :short, :title, :published, :published_time

  def publish
      self.published = true
      self.published_time = Time.now
      self.save
  end
  def self.all_published
    all :conditions => ['published = true AND published_time <= ?', Time.now]
  end

  rails_admin do

    field :title
    field :short
    field :long, :text do
      ckeditor true
    end
  end
end
