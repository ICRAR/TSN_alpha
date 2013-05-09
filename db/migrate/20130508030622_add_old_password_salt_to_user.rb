class AddOldPasswordSaltToUser < ActiveRecord::Migration
  def change
    add_column :users, :old_site_password_salt, :string, :null => false, :default => ""
  end
end
