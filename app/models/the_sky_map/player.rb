class TheSkyMap::Player < ActiveRecord::Base
  attr_accessible :rank, :score, :spent_points, :total_points, :total_points_special, :spent_points_special, as: [:admin]

  belongs_to :profile
  has_many :the_sky_map_players_quadrants, :class_name => 'TheSkyMap::PlayersQuadrant', foreign_key: "the_sky_map_player_id"
  has_many :the_sky_map_quadrants, :class_name => 'TheSkyMap::Quadrant', :through => :the_sky_map_players_quadrants
  has_many :the_sky_map_ships, :class_name => 'TheSkyMap::Ship', foreign_key: "the_sky_map_player_id"
  has_many :own_quadrants, :class_name => 'TheSkyMap::Quadrant', foreign_key: "owner_id"

  belongs_to :home, :class_name => 'TheSkyMap::Quadrant', :foreign_key => 'home_id'

  before_create :set_defaults
  def set_defaults
    rank = 0
    score = 0
    spent_points = 0
    total_points = 0
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
  def explore_quadrant(quadrant)
    #check for current join model
    pq = self.the_sky_map_players_quadrants.where{the_sky_map_quadrant_id == quadrant.id}.first
    if pq.nil?
      self.add_quadrant quadrant
      pq = self.the_sky_map_players_quadrants.where{the_sky_map_quadrant_id == quadrant.id}.first
    end
    pq.explored = true
    pq.save

    new = quadrant.surrounding_quadrants
    new.each do |q|
      self.add_quadrant q
    end

  end

  def add_quadrant(quadrant)
    begin
      self.the_sky_map_quadrants << quadrant
    rescue ActiveRecord::RecordInvalid => e
      rails e unless e.message == 'Validation failed: The sky map player has already been taken'
    end
  end

  #options
  def options_without_default
    opt = self[:options] || '{}'
    begin
      opt_hash = JSON.parse opt
    rescue TypeError, JSON::ParserError
      opt_hash = {}
    end
  end
  def self.options_default
    {
        'fog_of_war_on' => true
    }
  end
  def options
    TheSkyMap::Player.options_default.merge options_without_default
  end
  def set_options(hash)
    new_hash = options_without_default.merge hash
    self.options =  new_hash.to_json
  end
  def reset_option(key)
    new_hash = options_without_default
    new_hash.delete key
    self.options =  new_hash.to_json
  end

  #currency_methods
  def currency_available
    (total_points - spent_points)
  end
  def deduct_currency(value)
    self.class.where{id == self.id}.update_all("spent_points = spent_points + #{value.to_i}" )
  end
  def refund_currency(value)
    self.class.where{id == self.id}.update_all("spent_points = spent_points - #{value.to_i}" )
  end
  def currency_available_special
    (total_points_special - spent_points_special)
  end
  def deduct_currency_special(value)
    self.class.where{id == self.id}.update_all("spent_points_special = spent_points_special + #{value.to_i}" )
  end
  def refund_currency_special(value)
    self.class.where{id == self.id}.update_all("spent_points_special = spent_points_special - #{value.to_i}" )
  end

  #updates all players currency bassed on the hourly income rate and time since last update
  def self.update_currency
    current_time = Time.now
    old_time_i = SiteStat.try_get('the_sky_map/last_currency_update_time', current_time.to_i).value
    old_time = Time.at(old_time_i)
    time_diff = current_time - old_time
    time_diff_in_hours = time_diff/60/60
    self.update_all("total_points_float = total_points_float + (total_income * #{time_diff_in_hours}),"+
                        " total_points_special_float = total_points_special_float + (total_income_special * #{time_diff_in_hours})")
    self.update_all("total_points = total_points_float, total_points_special = total_points_special_float")


    SiteStat.set('the_sky_map/last_currency_update_time', current_time.to_i)
  end
  #updates the special income from RAC
  def self.update_special_income
    relation = TheSkyMap::Player.joins{profile.general_stats_item}

    #####
    # RAC to special currency is done here
    # total_income_special = LOG(recent_avg_credit)
    #####
    relation.update_all("#{TheSkyMap::Player.table_name}.total_income_special = LOG(#{GeneralStatsItem.table_name}.recent_avg_credit)")
  end


  #updates player rank
  def self.update_rankings
    TheSkyMap::Player.transaction do
      TheSkyMap::Player.connection.execute 'SET @new_rank := 0'
      TheSkyMap::Player.where{total_score > 0}.order{total_score.desc}.update_all('rank = @new_rank := @new_rank + 1')
    end
  end
end
