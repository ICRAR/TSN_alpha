class AddScienceProjectToPage < ActiveRecord::Migration
  def change
    change_table :pages do |t|
      t.belongs_to :science_portal
    end
  end
end
