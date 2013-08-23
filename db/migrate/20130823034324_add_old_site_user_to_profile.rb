class AddOldSiteUserToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :old_site_user, :boolean
  end
end
