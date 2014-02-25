class AddUseDisqusToNews < ActiveRecord::Migration
  def up
    add_column :news, :use_disqus, :boolean, :null => false, :default => false
    News.reset_column_information
    News.update_all(use_disqus: true)
  end

  def down
    remove_column :news, :use_disqus
  end
end
