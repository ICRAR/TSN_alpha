class AddDescriptionToSiteStat < ActiveRecord::Migration
  def change
    add_column :site_stats, :description, :string
    add_column :site_stats, :show_in_list, :boolean, :null => false, :default => false
    add_index :site_stats, :show_in_list, {name: 'show_index'}
    add_index :site_stats, :name, {name: 'name_index'}

  end
end
