class AddNamesToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :profile_name, :string
    add_column :activities, :item_name, :string
    add_column :activities, :avatar_url, :string
  end
end
