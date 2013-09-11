class AddNotifyToNews < ActiveRecord::Migration
  def change
    add_column :news, :notify, :boolean, :default => false
  end
end
