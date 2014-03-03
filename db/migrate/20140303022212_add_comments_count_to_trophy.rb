class AddCommentsCountToTrophy < ActiveRecord::Migration
  def change
    add_column :trophies, :comments_count, :integer
  end
end
