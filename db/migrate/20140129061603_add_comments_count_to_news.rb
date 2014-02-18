class AddCommentsCountToNews < ActiveRecord::Migration
  def change
    add_column :news, :comments_count, :integer
  end
end
