class AddBelongsToAllianceToProfile < ActiveRecord::Migration
  change_table :profiles do |t|
    t.belongs_to :alliance
    t.belongs_to :alliance_leader
  end
end
