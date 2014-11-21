class AddDeletedAtToActions < ActiveRecord::Migration
  def change
    add_column :actions, :deleted_at, :datetime
    add_index :actions, :deleted_at
  end
end

