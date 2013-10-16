class AddJoinedDateToUser < ActiveRecord::Migration
  def change
    add_column :users, :joined_at, :datetime
  end
end
