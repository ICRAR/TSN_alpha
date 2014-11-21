namespace :the_sky_map_generators do
  desc "generate element types"
  task :generate_types => :environment do

    #first create the quadrant types
    #Generate axis X: Galaxy size
    axis_x = {
        'A' => {
            score:          0,
            bases:          0,
            max_base_level: 0,
            gen_x_min:      0,
            gen_x_max:      239,
            suitable_for_home: false,
            generation_chance: 3,
        },
        'B' => {
            score:          50,
            bases:          1,
            max_base_level: 1,
            gen_x_min:      239,
            gen_x_max:      241,
            suitable_for_home: false,
            generation_chance: 6,
        },
        'C' => {
            score:          100,
            bases:          1,
            max_base_level: 2,
            gen_x_min:      241,
            gen_x_max:      404,
            suitable_for_home: false,
            generation_chance: 9,
        },
        'D' => {
            score:          150,
            bases:          2,
            max_base_level: 3,
            gen_x_min:      404,
            gen_x_max:      500,
            suitable_for_home: true,
            generation_chance: 9,
        },
        'E' => {
            score:          200,
            bases:          3,
            max_base_level: 4,
            gen_x_min:      500,
            gen_x_max:      10000,
            suitable_for_home: true,
            generation_chance: 6,
        }
    }
    axis_y = {
        '1' => {
            score:          50,
            max_base_level: 0,
            gen_y_min:      0,
            gen_y_max:      85,
            generation_chance: 0,
        },
        '2' => {
            score:          100,
            max_base_level: 1,
            gen_y_min:      85,
            gen_y_max:      170,
            generation_chance: 1,
        },
        '3' => {
            score:          200,
            max_base_level: 2,
            gen_y_min:      170,
            gen_y_max:      360,
            generation_chance: 2,
        },
    }
    #params for each quadrant type
    qts = []
    axis_x.each do |x_name, x_values|
      axis_y.each do |y_name, y_values|
        qts << {
            name: "Class #{x_name}#{y_name}",
            desc: '-',
            unexplored_name: "Class #{x_name}",
            num_of_bases: x_values[:bases],
            score: x_values[:score] + y_values[:score],
            feature_type: '-',
            generation_chance: x_values[:generation_chance] + y_values[:generation_chance],
            unexplored_symbol: x_name.downcase,
            explored_symbol: x_name,
            suitable_for_home: x_values[:suitable_for_home],
            gen_x_min: x_values[:gen_x_min],
            gen_x_max: x_values[:gen_x_max],
            gen_y_min: y_values[:gen_y_min],
            gen_y_max: y_values[:gen_y_max],
            max_base_level: x_values[:max_base_level] + y_values[:max_base_level],
            thumbnail_path: nil,
        }
      end
    end
    #mesc types
    qts << {
        name: "Mystery",
        desc: '-',
        unexplored_name: "?",
        num_of_bases: 1,
        score: 1000,
        feature_type: '-',
        generation_chance: 1,
        unexplored_symbol: '?',
        explored_symbol: 'M',
        suitable_for_home: false,
        gen_x_min: 0,
        gen_x_max: 0,
        gen_y_min: 0,
        gen_y_max: 0,
        max_base_level: 8,
        thumbnail_path: 'the_sky_map/mystery.jpg'
    }
    qts << {
        name: "Empty",
        desc: 'There is nothing here',
        unexplored_name: "Empty",
        num_of_bases: 0,
        score: 10,
        feature_type: '-',
        generation_chance: 60,
        unexplored_symbol: '-',
        explored_symbol: '=',
        suitable_for_home: false,
        gen_x_min: 0,
        gen_x_max: 0,
        gen_y_min: 0,
        gen_y_max: 0,
        max_base_level: 0,
        thumbnail_path: 'the_sky_map/empty.jpg'
    }
    #add quadrant types / check and update existing types
    qts.each do |hash|
      new_quad_type = TheSkyMap::QuadrantType.where({name: hash[:name]}).first_or_initialize
      new_quad_type.update_attributes(hash.except(*[:max_base_level]))
    end

    #TheSkyMap::QuadrantType.all.each{|t| puts t.find_galaxy}

    #next create the ship types
    base_cost = 10
    base_duration = 10.minutes
    ship_types = {
        'Basic Ship' => {
            desc: 'your first ship',
            attack: 1,
            health: 1,
            speed: 1,
            heal: 0,
            sensor_range: 1,
            cost_m: 1,
            duration_m: 1,
            can_build_bases: true
        },
        'Manned Ship' => {
            desc: '-',
            attack: 2,
            health: 2,
            speed: 1,
            heal: 1,
            sensor_range: 2,
            cost_m: 10,
            duration_m: 2,
            can_build_bases: true
        },
        'Fast Ship' => {
            desc: '-',
            attack: 2,
            health: 2,
            speed: 4,
            heal: 1,
            sensor_range: 2,
            cost_m: 30,
            duration_m: 3,
            can_build_bases: false
        },
        'Engineer Ship' => {
            desc: 'Good at healing',
            attack: 1,
            health: 2,
            speed: 2,
            heal: 3,
            sensor_range: 2,
            cost_m: 30,
            duration_m: 3,
            can_build_bases: true
        },
        'Ultra Attack ship' => {
            desc: '-',
            attack: 4,
            health: 4,
            speed: 1,
            heal: 1,
            sensor_range: 2,
            cost_m: 50,
            duration_m: 5,
            can_build_bases: false
        },
        'Long Range Sensor Ship' => {
            desc: '-',
            attack: 2,
            health: 3,
            speed: 2,
            heal: 1,
            sensor_range: 5,
            cost_m: 50,
            duration_m: 5,
            can_build_bases: false
        },
        'Ultimate Ship' => {
            desc: '-',
            attack: 6,
            health: 6,
            speed: 3,
            heal: 3,
            sensor_range: 5,
            cost_m: 1000,
            duration_m: 60,
            can_build_bases: true
        },
    }
    sts = []
    ship_types.each do |k,v|
      sts << v.except(*[:cost_m,:duration_m]).merge({
                                                        name: k ,
                                                        cost: v[:cost_m] * base_cost,
                                                        duration: v[:duration_m] * base_duration
                                                    })
    end
    #add quadrant types / check and update existing types
    sts.each do |hash|
      new_ship_type = TheSkyMap::ShipType.where({name: hash[:name]}).first_or_initialize
      new_ship_type.update_attributes(hash)
    end

    #next create the base types
    base_cost = 1000
    base_duration = 20.minutes
    base_income = 100
    base_score = 100
    bases_types = {
        'Base Base' => {
            desc: 'the most basic of the bases',
            build_level: 1,
            attack: 1,
            health: 4,
            cost_m: 1,
            duration_m: 1,
            income_m: 1,
            score_m: 1,
            upgrade_from: nil,
            builds_ships: []
        },
        'Shipyard' => {
            desc: 'a shipyard that can build ships',
            build_level: 2,
            attack: 1,
            health: 5,
            cost_m: 2,
            duration_m: 2,
            income_m: 1,
            score_m: 2,
            upgrade_from: 'Base Base',
            builds_ships: ['Basic Ship']
        },
        'Stellar Base' => {
            desc: 'An upgraded base base with more research potential',
            build_level: 3,
            attack: 1,
            health: 5,
            cost_m: 2,
            duration_m: 2,
            income_m: 2,
            score_m: 2,
            upgrade_from: 'Base Base',
            builds_ships: []
        },
        'Mine' => {
            desc: 'A hydrogen mine',
            build_level: 2,
            attack: 1,
            health: 5,
            cost_m: 2,
            duration_m: 2,
            income_m: 3,
            score_m: 2,
            upgrade_from: 'Base Base',
            builds_ships: []
        },
        'Defensive Base' => {
            desc: 'It has lots of guns',
            build_level: 2,
            attack: 3,
            health: 6,
            cost_m: 2,
            duration_m: 2,
            income_m: 1,
            score_m: 2,
            upgrade_from: 'Base Base',
            builds_ships: []
        },
        'Stellar Shipyard' => {
            desc: 'An advanced shipyard that can build bigger ships',
            build_level: 3,
            attack: 2,
            health: 6,
            cost_m: 3,
            duration_m: 3,
            income_m: 2,
            score_m: 3,
            upgrade_from: 'Shipyard',
            builds_ships: ['Basic Ship','Manned Ship']
        },
        'Bank' => {
            desc: 'LOTS of points',
            build_level: 3,
            attack: 2,
            health: 8,
            cost_m: 3,
            duration_m: 3,
            income_m: 2,
            score_m: 5,
            upgrade_from: 'Stellar Base',
            builds_ships: []
        },
        'Stellar Mine' => {
            desc: 'A bigger mine',
            build_level: 3,
            attack: 2,
            health: 6,
            cost_m: 3,
            duration_m: 3,
            income_m: 4,
            score_m: 3,
            upgrade_from: 'Mine',
            builds_ships: []
        },
        'Base Star Base' => {
            desc: 'It has a giant laser',
            build_level: 3,
            attack: 5,
            health: 8,
            cost_m: 3,
            duration_m: 3,
            income_m: 2,
            score_m: 3,
            upgrade_from: 'Defensive Base',
            builds_ships: []
        },
        'Engineering Base' => {
            desc: 'For researching better ships',
            build_level: 5,
            attack: 3,
            health: 7,
            cost_m: 4,
            duration_m: 4,
            income_m: 3,
            score_m: 4,
            upgrade_from: 'Stellar Base',
            builds_ships: ['Basic Ship','Manned Ship']
        },
        'Science Base' => {
            desc: 'For researching better mining',
            build_level: 5,
            attack: 3,
            health: 7,
            cost_m: 4,
            duration_m: 4,
            income_m: 4,
            score_m: 4,
            upgrade_from: 'Stellar Base',
            builds_ships: []
        },
        'Death Star Base' => {
            desc: 'The ultimate defensive base',
            build_level: 4,
            attack: 5,
            health: 10,
            cost_m: 4,
            duration_m: 4,
            income_m: 3,
            score_m: 4,
            upgrade_from: 'Base Star Base',
            builds_ships: []
        },
        'Engineering Lab' => {
            desc: 'For researching better ships',
            build_level: 6,
            attack: 3,
            health: 7,
            cost_m: 5,
            duration_m: 5,
            income_m: 3,
            score_m: 5,
            upgrade_from: 'Engineering Base',
            builds_ships: ['Basic Ship','Manned Ship']
        },
        'Galactic Shipyard' => {
            desc: 'Builds super fast ships',
            build_level: 5,
            attack: 3,
            health: 7,
            cost_m: 5,
            duration_m: 5,
            income_m: 3,
            score_m: 5,
            upgrade_from: 'Engineering Base',
            builds_ships: ['Basic Ship','Manned Ship','Fast Ship','Engineer Ship']
        },
        'Galactic Mine' => {
            desc: 'Awesome mining',
            build_level: 5,
            attack: 3,
            health: 7,
            cost_m: 5,
            duration_m: 5,
            income_m: 5,
            score_m: 5,
            upgrade_from: 'Science Base',
            builds_ships: []
        },
        'University Dept' => {
            desc: 'For researching better mining',
            build_level: 6,
            attack: 3,
            health: 7,
            cost_m: 5,
            duration_m: 5,
            income_m: 4,
            score_m: 5,
            upgrade_from: 'Science Base',
            builds_ships: []
        },
        'SKA' => {
            desc: 'For researching better ships',
            build_level: 7,
            attack: 4,
            health: 8,
            cost_m: 6,
            duration_m: 6,
            income_m: 3,
            score_m: 6,
            upgrade_from: 'Engineering Lab',
            builds_ships: ['Basic Ship','Manned Ship']
        },
        'Cluster Shipyard' => {
            desc: 'Builds awesome attack ships',
            build_level: 6,
            attack: 4,
            health: 8,
            cost_m: 6,
            duration_m: 6,
            income_m: 3,
            score_m: 6,
            upgrade_from: 'Engineering Lab',
            builds_ships: ['Basic Ship','Manned Ship','Fast Ship','Engineer Ship','Ultra Attack ship']
        },
        'Cluster Mine' => {
            desc: 'Amazing Mining',
            build_level: 6,
            attack: 4,
            health: 8,
            cost_m: 6,
            duration_m: 6,
            income_m: 6,
            score_m: 6,
            upgrade_from: 'University Dept',
            builds_ships: []
        },
        'ICRAR' => {
            desc: 'For researching better mining',
            build_level: 7,
            attack: 4,
            health: 8,
            cost_m: 6,
            duration_m: 6,
            income_m: 4,
            score_m: 6,
            upgrade_from: 'University Dept',
            builds_ships: []
        },
        'Supercluster Shipyard' => {
            desc: 'Builds the best ships',
            build_level: 7,
            attack: 4,
            health: 8,
            cost_m: 7,
            duration_m: 7,
            income_m: 3,
            score_m: 7,
            upgrade_from: 'SKA',
            builds_ships: ['Basic Ship','Manned Ship','Fast Ship','Engineer Ship','Ultra Attack ship','Long Range Sensor Ship']
        },
        'Supercluster Mine' => {
            desc: 'The best Mine',
            build_level: 7,
            attack: 4,
            health: 8,
            cost_m: 7,
            duration_m: 7,
            income_m: 7,
            score_m: 7,
            upgrade_from: 'ICRAR',
            builds_ships: []
        },
        'Mystery Mine' => {
            desc: '-',
            build_level: 8,
            attack: 5,
            health: 10,
            cost_m: 8,
            duration_m: 8,
            income_m: 8,
            score_m: 8,
            upgrade_from: nil,
            builds_ships: []
        },
        'Mystery Shipyard' => {
            desc: '-',
            build_level: 8,
            attack: 5,
            health: 10,
            cost_m: 8,
            duration_m: 8,
            income_m: 3,
            score_m: 8,
            upgrade_from: nil,
            builds_ships: ['Ultimate Ship']
        },
    }
    bases_types.each do |key,value|
      except_list = [:cost_m,:duration_m,:upgrade_from,:builds_ships,:income_m,:score_m,:build_level]
      new_base_hash = value.except(*except_list).merge({
          name: key,
          cost: value[:cost_m] * base_cost,
          duration: value[:duration_m] * base_duration,
          income: value[:income_m] * base_income,
          score: value[:score_m] * base_score,
                                                       })
      new_base_type = TheSkyMap::BaseUpgradeType.where({name: key}).first_or_initialize
      new_base_type.update_attributes(new_base_hash)
      #check parent
      if value[:upgrade_from].nil?
        #is a root base so no parent
        new_base_type.parent = nil
      else
        parent_base_type = TheSkyMap::BaseUpgradeType.where({name: value[:upgrade_from]}).first
        new_base_type.parent = parent_base_type
      end
      #check ships
      required_ship_type_ids = TheSkyMap::ShipType.where{name.in value[:builds_ships]}.pluck(:id)
      new_base_type.the_sky_map_ship_type_ids = required_ship_type_ids
      #check quadrants
      level_needed = value[:build_level]
      required_quadrant_type_names = []
      qts.each do |quadrant_hash|
        required_quadrant_type_names << quadrant_hash[:name] if quadrant_hash[:max_base_level] >= level_needed
      end
      required_quadrant_type_ids = TheSkyMap::QuadrantType.where{name.in required_quadrant_type_names}.pluck(:id)
      new_base_type.the_sky_map_quadrant_type_ids = required_quadrant_type_ids
      new_base_type.save
    end

  end
  desc "clear object types"
  task :reset_types => :environment do
    TheSkyMap::QuadrantType.destroy_all
    TheSkyMap::BaseUpgradeType.destroy_all
    TheSkyMap::ShipType.destroy_all

  end
  desc "clear game objects"
  task :reset_types => :environment do
    TheSkyMap::Player.destroy_all
    TheSkyMap::Quadrant.destroy_all
    TheSkyMap::Ship.destroy_all
    TheSkyMap::Base.destroy_all

  end
  desc "builds a new 20x20 map"
  task :build_map => :environment do
    TheSkyMap::Quadrant.generate_new_area(0..20,0..20,1..1)

  end
  desc "add new player"
  task :build_map => :environment do
    profile = Profile.find 9101
    TheSkyMap::Player.build_new_player(profile)

  end

end
