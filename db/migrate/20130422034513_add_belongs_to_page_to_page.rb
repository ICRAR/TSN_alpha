class AddBelongsToPageToPage < ActiveRecord::Migration
  def up
    add_column :pages, :parent_id, :integer
    Page.reset_column_information
  end

  def down
    remove_column :pages, :parent_id
  end
end
