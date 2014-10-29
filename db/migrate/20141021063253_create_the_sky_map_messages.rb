class CreateTheSkyMapMessages < ActiveRecord::Migration
  def change
    create_table :the_sky_map_messages do |t|
      t.string :msg
      t.references :the_sky_map_player
      t.references :the_sky_map_quadrant
      t.boolean :ack, default: false

      t.timestamps
    end
    add_index :the_sky_map_messages, [:the_sky_map_player_id, :created_at, :ack], {name: 'the_sky_map_messages_player_index'}
  end
end
