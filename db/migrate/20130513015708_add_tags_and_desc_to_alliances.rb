class AddTagsAndDescToAlliances < ActiveRecord::Migration
  def change
    add_column :alliances, :tags, :string
    add_column :alliances, :desc, :text
    add_column :alliances, :country, :string
  end
end
