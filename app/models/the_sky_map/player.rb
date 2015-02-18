class TheSkyMap::Player < ActiveRecord::Base
  extend Memoist
  attr_accessible :rank, :score, :spent_points, :total_points, :game_map_id, :total_points_special,
                  :colour_id, :spent_points_special, :current, :options, as: [:admin]

  belongs_to :profile
  scope :only_current, where{current == true}
  has_many :the_sky_map_players_quadrants, :class_name => 'TheSkyMap::PlayersQuadrant', foreign_key: "the_sky_map_player_id"
  has_many :the_sky_map_quadrants, :class_name => 'TheSkyMap::Quadrant', :through => :the_sky_map_players_quadrants
  has_many :the_sky_map_ships, :class_name => 'TheSkyMap::Ship', foreign_key: "the_sky_map_player_id"
  has_many :own_quadrants, :class_name => 'TheSkyMap::Quadrant', foreign_key: "owner_id"
  has_many :messages, :class_name => 'TheSkyMap::Message', foreign_key: "the_sky_map_player_id"

  belongs_to :home, :class_name => 'TheSkyMap::Quadrant', :foreign_key => 'home_id'
  belongs_to :game_map, :class_name => 'TheSkyMap::GameMap', :foreign_key => 'game_map_id'

  def self.colours
    ['Brown','Coral','DarkGoldenRod','DarkGreen','DeepPink','DarkOrchid ','Gold','LightGreen','Cyan','PaleVioletRed']
  end
  def self.colour_from_id(c_id)
    num_colours = colours.size
    c_id = c_id % num_colours
    colours[c_id]
  end
  def colour
    c_id = colour_id || 0
    self.class.colour_from_id c_id
  end
  def self.for_index(player)
    self.where{rank > 0}.order{rank.asc}.includes(:profile).where{game_map_id == my{player.game_map_id}}
  end
  def self.for_show(player,id)
    self.where{game_map_id == my{player.game_map_id}}.find(id)
  end
  before_create :set_defaults
  def set_defaults
    self.rank = 0
    self.score = 0
    self.spent_points_special = 0
    self.total_points_special = 0
    self.total_points_special_float = 0
    self.spent_points = 0
    self.total_points = 0
    self.total_points_float = 0
  end

  def can_perform_actions?
    game_map.can_players_perform_actions?
  end

  #sends the player a msg and links to the quadrant
  def send_msg(msg,opts = {})
    new_msg = TheSkyMap::Message.new_message(self,msg, opts)
    #push to open windows
    PostToFaye.new_msg(self.id,new_msg.id,self.unread_msg_count,self.game_map_id)
  end
  def unread_msg_count
    self.messages.where{ack==false}.count
  end
  def has_unread_msgs
    self.unread_msg_count > 0
  end

  #accepts a location in the form of {x:1,y:1} that the system will try to award as the home
  def self.build_new_player(game_map_id_set,profile,loc = nil)
    #check that the profile dosen't already have a player for this map
    return false unless profile.the_sky_map_players.where{game_map_id == my{game_map_id_set}} == []
    #creates new player object
    new_player = self.new
    #sets defaults
    new_player.set_defaults
    new_player.profile = profile
    new_player.game_map_id = game_map_id_set
    new_player.save
    #find a new home & claim home
    new_player.home = TheSkyMap::Quadrant.find_new_home(game_map_id_set,{location: loc})
    return false if new_player.home.nil?
    #capture home
    new_player.home.owner = new_player
    new_player.home.save
    #explore area around home
    new_player.explore_quadrant(new_player.home)

    #add base to home
    home_base_type = TheSkyMap::BaseUpgradeType.where{name == 'Home'}.first
    TheSkyMap::Base.first_base(new_player.home, home_base_type)

    #add ship to home
    ship_type = TheSkyMap::ShipType.where{name == 'Basic Ship'}.first
    return false if ship_type.nil?
    new_ship = ship_type.build_new(new_player.home,new_player)

    #update score
    new_player.update_special_income
    new_player.update_total_income
    new_player.update_total_score

    #add initial currency
    new_player.total_points_special = 100
    new_player.total_points_special_float = 100
    new_player.total_points = 1000
    new_player.total_points_float = 1000

    new_player.save


    #update all player rankings
    self.update_rankings
    #yay your ready to go
    new_player

  end


  #actor methods
  acts_as_actor

  def update_total_income
    new_total= self.own_quadrants.sum("#{own_quadrants.table_name}.total_income").to_i
    self.total_income = new_total
    new_total
  end
  def update_total_score
    new_total= self.own_quadrants.sum("#{own_quadrants.table_name}.total_score").to_i
    self.total_score = new_total
    new_total
  end
  def update_totals
    update_total_income
    update_total_score
    save
  end
  def explore_quadrant(quadrant,distance = 1)
    #check for current join model
    pq = self.the_sky_map_players_quadrants.where{the_sky_map_quadrant_id == quadrant.id}.first
    newly_explored = []
    if pq.nil?
      newly_explored << quadrant.id if self.add_quadrant(quadrant)
      pq = self.the_sky_map_players_quadrants.where{the_sky_map_quadrant_id == quadrant.id}.first
    end
    pq.explored = true
    pq.save

    new = quadrant.surrounding_quadrants(distance)
    new.each do |q|
      newly_explored << q.id if self.add_quadrant(q)
    end

    newly_explored
  end

  def add_quadrant(quadrant)
    begin
      self.the_sky_map_quadrants << quadrant
      return true
    rescue ActiveRecord::RecordInvalid => e
      rails e unless e.message == 'Validation failed: The sky map player has already been taken'
      return false
    end
  end

  #options
  acts_as_optionable
  def options_default
    {
        'fog_of_war_on' => true,
        'mini_map_x_min' => 1,
        'mini_map_x_max' => 20,
        'mini_map_y_min' => 1,
        'mini_map_y_max' => 20,

    }
  end


  #currency_methods
  def currency_available
    (total_points - spent_points)
  end
  def deduct_currency(value)
    self.class.where{id == my{self.id}}.update_all("spent_points = spent_points + #{value.to_i}" )
  end
  def refund_currency(value)
    self.class.where{id == my{self.id}}.update_all("spent_points = spent_points - #{value.to_i}" )
  end
  def currency_available_special
    (total_points_special - spent_points_special)
  end
  def deduct_currency_special(value)
    self.class.where{id == my{self.id}}.update_all("spent_points_special = spent_points_special + #{value.to_i}" )
  end
  def refund_currency_special(value)
    self.class.where{id == my{self.id}}.update_all("spent_points_special = spent_points_special - #{value.to_i}" )
  end

  def award_currency(value)
    self.class.where{id == my{self.id}}.update_all(
        "total_points_float = total_points_float + #{value.to_i},"+
            "total_points = total_points + #{value.to_i}"
    )
  end
  def award_currency_special(value)
    self.class.where{id == my{self.id}}.update_all(
        "total_points_special_float = total_points_special_float + #{value.to_i},"+
            "total_points_special = total_points_special + #{value.to_i}"
    )
  end

end
