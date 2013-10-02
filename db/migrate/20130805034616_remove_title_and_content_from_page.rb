class RemoveTitleAndContentFromPage < ActiveRecord::Migration
  def up
    remove_column :pages, :title
    remove_column :pages, :content
  end

  def down
    add_column :pages, :content, :text
    add_column :pages, :title, :string
  end
end
