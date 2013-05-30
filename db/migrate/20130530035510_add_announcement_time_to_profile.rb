class AddAnnouncementTimeToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :announcement_time, :datetime, :default => nil
    Profile.reset_column_information
    Profile.all.each do |p|
      p.update_attribute :announcement_time, nil
    end
  end
end
