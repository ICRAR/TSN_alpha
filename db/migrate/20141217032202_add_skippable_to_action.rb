class AddSkippableToAction < ActiveRecord::Migration
  def change
    add_column :actions, :skippable, :boolean
  end
end
