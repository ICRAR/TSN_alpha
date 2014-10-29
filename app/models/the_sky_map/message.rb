class TheSkyMap::Message < ActiveRecord::Base
  attr_accessible :msg, :the_sky_map_quadrant, :the_sky_map_player, :ack, as: [:admin, :default]
  belongs_to :the_sky_map_quadrant, :class_name => 'TheSkyMap::Quadrant', foreign_key: "the_sky_map_quadrant_id"
  belongs_to :the_sky_map_player, :class_name => 'TheSkyMap::Player', foreign_key: "the_sky_map_player_id"

  scope :for_show, -> {order("#{self.table_name}.created_at desc")}

  def self.new_message(player,msg,quadrant = nil)
    nm = self.new({
        msg: msg,
        ack: false,
        the_sky_map_player: player,
        the_sky_map_quadrant: quadrant
                    })
    nm.save
    nm
  end
  def self.ack_msg(id)
    self.update(id, ack: true)
  end
  def ack_msg
    self.update_attribute(:ack, true)
  end
end
