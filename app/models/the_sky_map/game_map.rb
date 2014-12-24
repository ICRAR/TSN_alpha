class TheSkyMap::GameMap < ActiveRecord::Base
  attr_accessible :x_min, :x_max, :y_min, :y_max, :options, :state, :running_at, :finished_at, as: [:default, :admin]

  has_many :the_sky_map_players, :class_name => 'TheSkyMap::Player', foreign_key: "game_map_id"
  has_many :the_sky_map_quadrants, :class_name => 'TheSkyMap::Quadrant', foreign_key: "game_map_id"
  belongs_to :manager, :class_name => 'Profile', :foreign_key => 'manager_id'

  #has_many actions through the_sky_map_players
  def actions
    Action.joins{actor(TheSkyMap::Player)}.where{actor_type == "TheSkyMap::Player"}.where{the_sky_map_players.game_map_id == my{self.id}}
  end

  def states  #do not change numbers only add new ones, order of numbers has no meaning
    {
        0 => :new,
        1 => :ready,
        2 => :running,
        3 => :finishing,
        4 => :finished,
    }
  end
  acts_as_stateable
  def joinable?
    self.options[:join_while_running] ?
      [:ready, :running].include? current_state :
      [:ready].include? current_state
  end
  def x_size
    x_max - x_min + 1
  end
  def y_size
    y_max - y_min + 1
  end
  #builds all the tiles for a new map
  def build_tiles
    x_range = (self.x_min..self.x_max)
    y_range = (self.y_min..self.y_max)
    TheSkyMap::Quadrant.generate_new_area(x_range, y_range, self.id)
  end
  #adds a new player to the map
  def add_player(profile)
    new_player = TheSkyMap::Player.build_new_player(self.id,profile)
    self.set_player_colour new_player

  end
  def set_player_colour(player)
    new_id = self.the_sky_map_players.maximum(:colour_id) || -1
    player.colour_id = new_id + 1
    player.save
  end
  def reset_all_player_colours
    self.the_sky_map_players.update_all(colour_id: nil)
    self.the_sky_map_players.each do |player|
      self.set_player_colour player
    end
  end

  #####Game update functions#######
  def update_map
    self.update_stats
    self.end_game if self.check_end_condition
  end
  def update_stats
    #first update special income from RAC values
    #self.update_special_income
    #temp hack to update RAC from main server
    self.the_sky_map_players.each do |player|
      remote = HTTParty.get("http://www.theskynet.org/profiles/#{player.profile_id}.json")
      puts "checking http://www.theskynet.org/profiles/#{player.profile_id}.json"
      unless remote.parsed_response['result']['profile'].nil?
        rac = remote.parsed_response['result']['profile']['boinc_stats_item']['RAC']
        income = Math.log([rac,1].max)
        player.total_income_special = income
        player.save
      end
    end
    #first update both currencies
    self.update_currency

    #update player rankings
    self.update_rankings
  end

  #update currencys
  def update_currency
    current_time = Time.now
    old_time_i = SiteStat.try_get('the_sky_map/last_currency_update_time', current_time.to_i).value
    old_time = Time.at(old_time_i)
    time_diff = current_time - old_time
    time_diff_in_hours = time_diff/60/60
    self.the_sky_map_players.update_all("total_points_float = total_points_float + (total_income * #{time_diff_in_hours}),"+
                        " total_points_special_float = total_points_special_float + (total_income_special * #{time_diff_in_hours})")
    self.the_sky_map_players.update_all("total_points = total_points_float, total_points_special = total_points_special_float")


    SiteStat.set('the_sky_map/last_currency_update_time', current_time.to_i)
  end
  #updates the special income from RAC
  def update_special_income
    relation = self.the_sky_map_players.joins{profile.general_stats_item}

    #####
    # RAC to special currency is done here
    # total_income_special = LOG(recent_avg_credit)
    #####
    relation.update_all("#{TheSkyMap::Player.table_name}.total_income_special = LOG(GREATEST(COALESCE(#{GeneralStatsItem.table_name}.recent_avg_credit,0),1))")
  end

  #updates player rank
  def update_rankings
    TheSkyMap::Player.transaction do
      TheSkyMap::Player.connection.execute 'SET @new_rank := 0'
      self.the_sky_map_players.where{total_score > 0}.order{total_score.desc}.update_all('rank = @new_rank := @new_rank + 1')
    end
  end

  #checks if the end condtion has been met
  def check_end_condition
    ended = false
    if is_running?
      case options[:end_condition]
        when 'time'
          ended = true if Time.now > options[:end_time]
      end
    end
    ended
  end


  #####Game control functions######
  #create a new game
  def self.new_game(manager_profile, options)
    #validate params
    options = options.compile_options({
        required: [:x_size,:y_size,:game_options],
                           })
    map_options = self.valid_game_options options[:game_options]

    #setup game map
    map = self.new({
                          x_min: 1,
                          x_max: options[:x_size] + 1,
                          y_min: 1,
                          y_max: options[:y_size] + 1
                      })
    map.state = :new
    map.set_options map_options
    map.manager = manager_profile
    map.save
    map.build_tiles
    #add initial player
    map.add_player(manager_profile)
    #mark map has ready
    map.state = :ready
    map.save
    map
  end
  #starts a game
  def start_game
    return false unless is_ready?
    #mark game as started
    self.state= :running
    self.save
    #notify all players


  end
  #finish a game
  def end_game
    #marks the game as finished preventing more actions
    return false unless is_running?
    self.state= :finishing
    self.save
    #refunds any pending actions
    the_sky_map_players.each do |player|
      Action.refund_action_to_actor(player)
    end
    #finalises player scores
    self.update_stats
    self.state= :finsihed
    self.save
    return true
  end

  #options
  acts_as_optionable
  def options_default
    {
      end_condition:        'time',
      join_while_running:   false
    }
  end
  def validates_game_options
    required_options = [:join_while_running,:end_condition]
    allowed_options = required_options + [:game_length]
    options.each_key do |key|
      errors.add(:options, "game option key:#{key} is not a valid key") unless allowed_options.include?(key)
    end
    required_options.each do |key|
      errors.add(:options, "game option key:#{key} is missing") unless options.has_key?(key)
    end

    if options[:end_condition] == 'time'
      errors.add(:options, "game option key:#{:game_length} is missing") unless options.has_key?(:game_length)
      errors.add(:options, "game option key:#{:game_length} is out of range, must be greater than 1 day") unless options[:game_length] > 1.day
      errors.add(:options, "game option key:#{:game_length} is out of range, must be less than 30 days") unless options[:game_length] < 30.day
    end
  end

end
