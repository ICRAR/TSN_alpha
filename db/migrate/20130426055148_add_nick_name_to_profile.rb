class AddNickNameToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :nickname, :string
    add_column :profiles, :use_full_name, :boolean, :default => true
  end
end
