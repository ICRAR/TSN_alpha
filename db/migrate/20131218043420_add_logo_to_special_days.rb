class AddLogoToSpecialDays < ActiveRecord::Migration
  def self.up
    add_attachment :special_days, :logo
  end

  def self.down
    remove_attachment :special_days, :logo
  end
end
