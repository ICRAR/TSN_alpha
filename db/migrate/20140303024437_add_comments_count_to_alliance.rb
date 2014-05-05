class AddCommentsCountToAlliance < ActiveRecord::Migration
  def change
    add_column :alliances, :comments_count, :integer
  end
end
