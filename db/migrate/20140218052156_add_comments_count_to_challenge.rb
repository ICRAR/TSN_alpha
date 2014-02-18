class AddCommentsCountToChallenge < ActiveRecord::Migration
  def change
    add_column :challenges, :comments_count, :integer
  end
end
