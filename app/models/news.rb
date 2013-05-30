class News < ActiveRecord::Base
  attr_accessible :long, :short, :title, :published, :published_time, as: :admin

  def publish
      self.published = true
      self.published_time = Time.now
      self.save
  end
  scope :published, where('published = true AND published_time <= ?', Time.now)
  rails_admin do

    field :title
    field :short
    field :published
    field :published_time
    field :long, :text do
      ckeditor true
    end
  end

  def self.announcement(time)
      time ||= Time.at(0)
      where('published = true AND published_time > ?', time).order('published_time ASC').first
  end
end
