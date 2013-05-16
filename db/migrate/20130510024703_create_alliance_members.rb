class CreateAllianceMembers < ActiveRecord::Migration
  def change
    create_table :alliance_members do |t|
      t.datetime :join_date
      t.datetime :leave_date
      t.integer :start_credit
      t.integer :leave_credit
      t.belongs_to :alliance
      t.belongs_to :profile


      t.timestamps
    end
  end
end
