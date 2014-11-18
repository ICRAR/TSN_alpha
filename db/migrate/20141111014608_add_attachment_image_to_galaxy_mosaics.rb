class AddAttachmentImageToGalaxyMosaics < ActiveRecord::Migration
  def self.up
    change_table :galaxy_mosaics do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :galaxy_mosaics, :image
  end
end
