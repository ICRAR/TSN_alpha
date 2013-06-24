class CreateAllianceInvites < ActiveRecord::Migration
  def change
    create_table :alliance_invites do |t|
      t.belongs_to :invited_by
      t.belongs_to :redeemed_by
      t.belongs_to :alliance
      t.belongs_to
      t.string :token
      t.boolean :used
      t.string :email
      t.timestamp :invited_on
      t.timestamp :redeemed_on, :null=> true

      t.timestamps
    end
  end
end
