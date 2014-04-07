class AddCommentsCountToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :comments_count, :integer
  end
end
