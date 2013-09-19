class AddPreviewToPages < ActiveRecord::Migration
  def change
    add_column :pages, :preview, :boolean, :null => false, :default => false
    add_column :pages, :sort_order, :integer
  end
end
