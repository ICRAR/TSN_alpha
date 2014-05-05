class AddInviteCodeToChallenge < ActiveRecord::Migration
  def change
    add_column :challenges, :invite_code, :string
  end
end
