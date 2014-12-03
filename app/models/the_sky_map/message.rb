class TheSkyMap::Message < ActiveRecord::Base
  acts_as_taggable
  attr_accessible :msg, :the_sky_map_quadrant, :the_sky_map_player, :ack, as: [:admin, :default]
  belongs_to :the_sky_map_quadrant, :class_name => 'TheSkyMap::Quadrant', foreign_key: "the_sky_map_quadrant_id"
  belongs_to :the_sky_map_player, :class_name => 'TheSkyMap::Player', foreign_key: "the_sky_map_player_id"

  scope :for_show, -> {order("#{self.table_name}.created_at desc").includes(:tags)}

  def self.new_message(player,msg,opts = {})
    opts.compile_options(
        defaults: {quadrant: nil, tags: []},
        asserts: [:quadrant, :tags]
    )
    nm = self.new({
        msg: msg,
        ack: false,
        the_sky_map_player: player,
        the_sky_map_quadrant: opts[:quadrant]
                    })
    nm.tag_list.add opts[:tags]
    nm.save
    nm
  end
  def self.ack_msg(id)
    self.update(id, ack: true)
  end
  def ack_msg
    self.update_attribute(:ack, true)
  end
  def self.tag_list
    ActsAsTaggableOn::Tag.joins{taggings}.where{taggings.taggable_type == "TheSkyMap::Message"}.pluck(:name).uniq
  end
end
