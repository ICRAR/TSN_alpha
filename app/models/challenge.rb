class Challenge < ActiveRecord::Base
  attr_accessible :name, :desc, :end_date, :handicap_type, :start_date, :invite_only, :challenge_system, :challenger_type, :project, :join_while_running, as: [:admin, :default]
  attr_accessible :invite_code, :manager_id, :started, :finished, :hidden, as: [:admin]
  has_many :challengers
  belongs_to :manager, class_name: 'Profile'
  def self.not_hidden(admin = false)
    if admin == true
      self.scoped
    else
      where{hidden == false}
    end
  end

  def self.find_by_profile(profile)
    joins{challengers}.
    where{(challengers.entity_type == 'Profile') & (challengers.entity_id == profile.id)}.
    select('*').select{challengers.rank.as 'rank'}
  end
  def self.find_by_profile_alliance(profile)
    if profile.alliance_id.nil?
      nil
    else
      joins{challengers}.
      where{(challengers.entity_type == 'Alliance') & (challengers.entity_id == profile.alliance_id)}.
      select('*').select{challengers.rank.as 'rank'}
    end
  end
  has_many :comments, as: :commentable
  attr_readonly :comments_count

  def challenger_type_enum
    ['Profile', 'Alliance']
    end
  def handicap_type_enum
    ['None','RAC', 'Num_Members']
  end
  def challenge_system_enum
    ['Credit', 'RAC', 'Peak_RAC', 'Peak_Active_Members', 'New_Members', 'Change_in_rank']
  end
  def project_enum
    ['All']
  end

  before_save :update_invite_only
  def update_invite_only
    if invite_only_changed? && invite_only?
      self.generate_invite_code
    end
  end


=begin
  Each challenge id defiend using several type options
  Project: Which projects will influence this challenge, currently only all as an option
  Challenger Type: which object is the challenger currently: Profile and Alliance possible add County in the future
  Challenge System: system for determining the score
  Handicap: Handicap if any. set to 'None' for no handicap

Options for each challenge type is set with the allowed_types_hash.
  which is a cascading hash project -> challenger type -> challenge system
  This creates a unique options hash for each different challenge type (options_hash)
within the options hash are the following options:
  handicap_types: hash of allowed handicap options
  join_option: the method is sent to the challenger object before any update queries are performed. this can be used to set join and where options ect for the challenger model
  start_query: an MY SQL update query called when the challenge is first started. used to set the start value
    seting start_query to '' means each challenger will be initialised to 0
  start_query: an MY SQL update query called when the challenge is updated. used to set the save value
Similar options are used to the handicap_options_hash

Finally the score value is set in the update action using the following formula:
  (save_value - start) * handicap

=end
  def allowed_types_hash
    {
        all: {
            profile: {
                rac: {
                    handicap_types: {none: true},
                    join_option: :joins_profile_with_gsi,
                    start_query: 'challengers.start = IFNULL(g.recent_avg_credit,0)',
                    update_query: 'challengers.save_value = g.recent_avg_credit'
                },
                credit: {
                    handicap_types: {none: true, rac: true},
                    join_option: :joins_profile_with_gsi,
                    start_query: 'challengers.start = g.total_credit',
                    update_query: 'challengers.save_value = g.total_credit'
                },
                peak_rac: {
                    handicap_types: {none: true, rac: true},
                    join_option: :joins_profile_with_gsi,
                    start_query: '',
                    update_query: 'challengers.save_value = GREATEST(IFNULL(g.recent_avg_credit,0),IFNULL(challengers.save_value,0))'
                },
                change_in_rank: {
                    handicap_types: {none: true},
                    join_option: :joins_profile_with_gsi,
                    start_query: 'challengers.start = IFNULL(g.rank,0)',
                    update_query: 'challengers.save_value = IFNULL(g.rank,0)'
                }
            },
            alliance: {
                rac: {
                    handicap_types: {none: true, num_members: true},
                    join_option: :joins_alliance,
                    start_query: 'challengers.start = IFNULL(a.RAC,0)',
                    update_query: 'challengers.save_value = a.RAC'
                },
                credit: {
                    handicap_types: {none: true, rac: true, num_members: true},
                    join_option: :joins_alliance,
                    start_query: 'challengers.start = a.credit',
                    update_query: 'challengers.save_value = a.credit'
                },
                peak_rac: {
                    handicap_types: {none: true, rac: true, num_members: true},
                    join_option: :joins_alliance,
                    start_query: '',
                    update_query: 'challengers.save_value = GREATEST(IFNULL(a.RAC,0),IFNULL(challengers.save_value,0))'
                },
                peak_active_members: {
                    handicap_types: {none: true},
                    join_option: :joins_alliance_active_members,
                    start_query: '',
                    update_query: 'challengers.save_value = GREATEST(IFNULL(count_table.count,0),IFNULL(challengers.save_value,0))'
                },
                new_members: {
                    handicap_types: {none: true},
                    join_option: :joins_alliance_all_members,
                    start_query: 'challengers.start = count_table.count',
                    update_query: 'challengers.save_value = count_table.count'
                },
                change_in_rank: {
                    handicap_types: {none: true},
                    join_option: :joins_alliance,
                    start_query: 'challengers.start = IFNULL(a.ranking,0) * -1',
                    update_query: 'challengers.save_value = IFNULL(a.ranking,0) * -1'
                }
            }
        }
    }
  end
  def options_hash
    allowed_types_hash[project.downcase.to_sym][challenger_type.downcase.to_sym][challenge_system.downcase.to_sym]
  end
  def handicap_hash
    {
        all: {
            profile: {
                rac: {
                    join_option: :joins_profile_with_gsi,
                    handicap_query: 'challengers.handicap = 1000 / GREATEST(IFNULL(g.recent_avg_credit,0),1)'
                }
            },
            alliance: {

                rac: {
                    join_option: :joins_alliance,
                    handicap_query: 'challengers.handicap = 100000 / GREATEST(IFNULL(a.RAC,0),1)'
                },

                num_members: {
                    join_option: :joins_alliance_active_members,
                    handicap_query: 'challengers.handicap = 100 / GREATEST(IFupdate_queryNULL(count_table.count,0),1)'
                }
            }
        }
    }
  end
  def handicap_options_hash
    handicap_hash[project.downcase.to_sym][challenger_type.downcase.to_sym][handicap_type.downcase.to_sym]
  end
  validate :allowed_types
  def allowed_types
    return if project.nil?
    check_project = allowed_types_hash[project.downcase.to_sym]
    if check_project.class != Hash
      errors.add(:project, "Project Not supported")
    else
      return if challenger_type.nil?
      check_challenger = check_project[challenger_type.downcase.to_sym]
      if check_challenger.class != Hash
        errors.add(:challenger_type, "Challenger Type not supported for this project")
      else
        return if challenge_system.nil?
        check_system = check_challenger[challenge_system.downcase.to_sym]
        if check_system.class != Hash
          errors.add(:challenge_system, "Challenge System not supported for this Challenger Type")
        else
          return if handicap_type.nil? || handicap_type == 'None'
          check_handicap = check_system[:handicap_types][handicap_type.downcase.to_sym]
          errors.add(:handicap_type, "Handicap Type not supported for this challenge type") unless check_handicap == true
        end
      end
    end
  end

  validates_presence_of :name, :desc, :start_date, :end_date, :challenger_type, :handicap_type, :challenge_system, :project, :manager_id
  validates_uniqueness_of :name
  validate :start_in_future, :on => :create
  def start_in_future
    errors.add(:start_date, "Start date must be in the future") if start_date.nil? || start_date < Time.now
  end
  validate :start_before_end
  def start_before_end
    errors.add(:start_date, "Start date must be before end date") if end_date.nil? || start_date.nil? || end_date < start_date
  end
  validate :length_of_challenge_validates
  def length_of_challenge_validates
    errors.add(:start_date, "Length of challenge must be greater than 24 hours") if end_date.nil? || start_date.nil? || length_hours < 24
    errors.add(:start_date, "Length of challenge must be less than 31 days") if end_date.nil? || start_date.nil? || length_days > 31
  end

  def length_hours
    ((end_date - start_date)/1.hour).round
  end
  def length_days
    length_hours / 24
  end

  def running?
    started && !finished
  end

  def joinable?(check_code = '')
    if invite_only?
      #check invite code
      return false unless (invite_code != nil && invite_code != '') && check_code == invite_code
    end
    return ((running? && join_while_running?) || !started)
  end

  def status
    case
      when !started?
        'Upcoming'
      when running?
        'Running'
      when finished?
        'Finished'
      else
        'Unknown'
    end
  end

  def join(entity,check_code = '')
    #double check entity is allowed to join
    return false unless self.joinable?(check_code)
    #create new challenger object
    new_challenger = Challenger.new(
        challenge: self,
        entity: entity
    )

    #fix for join whilst running

    if new_challenger.save
      if self.running?
        #fix for join whilst running
        challenger_relation = challengers.where{id == new_challenger.id}
        #set the start value, save_value, set rank to max value
        update_query = options_hash[:start_query] == '' ? 'challengers.start = 0' : options_hash[:start_query]
        update_query << ', '
        update_query << options_hash[:update_query]
        update_query << ", challengers.rank = #{challengers.count}"
        challenger_relation.send(options_hash[:join_option]).update_all(update_query)

        #set the handicap value
        if handicap_type == 'None'
          challenger_relation.update_all('challengers.handicap = 1.0')
        else
          challenger_relation.send(handicap_options_hash[:join_option]).update_all(handicap_options_hash[:handicap_query])
        end
        #set the score value
        challenger_relation.update_all('challengers.score = (challengers.save_value - challengers.start) * challengers.handicap')

      end
    end
    return new_challenger


  end

  def add_start_job
    Challenge.delay({run_at: self.start_date}).start_challenge(self.id)
  end

  def self.start_challenge(challenge_id)
    c = Challenge.find challenge_id
    c.start_challenge
  end
  def self.end_challenge(challenge_id)
    c = Challenge.find challenge_id
    c.end_challenge
  end

  def start_challenge
    unless started?
      self.started = true
      self.finished = false
      #update stats then schedule next update
      if options_hash[:start_query] == ''
        challengers.update_all('challengers.start = 0')
      else
        challengers.send(options_hash[:join_option]).update_all(options_hash[:start_query])
      end

      #update handicap values
      update_handicap

      self.update_stats
      Challenge.delay({run_at: 1.hour.from_now}).update_stats(self.id)
      self.started = true
      self.finished = false
      self.next_update_time = 1.hour.from_now
      self.save
      #send out notifications



      #add end job
      Challenge.delay({run_at: self.end_date}).end_challenge(self.id)
    end
  end
  def end_challenge
    if running? && !finished?
      self.update_stats
      self.finished = true
      self.save
      #send out notifications
    end
  end

  def self.update_stats(challenge_id)
    c = Challenge.find challenge_id
    c.update_stats

    #reschedule update to run again in another 30 mins unless end time is within 30mins
    next_update = 1.hour.from_now
    if c.end_date > next_update
      c.next_update_time = next_update
      c.save
      Challenge.delay({run_at: next_update}).update_stats(c.id)
    else
      c.next_update_time = c.end_date
      c.save
    end
  end

  def update_stats
    return false unless self.running?
    #update save value
    challengers.send(options_hash[:join_option]).update_all(options_hash[:update_query])
    #update score
    challengers.update_all('challengers.score = (challengers.save_value - challengers.start) * challengers.handicap')
    #update scores metrics
    ChallengeData.insert challengers.select("'Challenger', challengers.id, 0, Now(), challengers.score")
    #update ranks
    Challenge.transaction do
      Challenge.connection.execute 'SET @new_rank := 0'
      challengers.order{score.desc}.update_all('rank = @new_rank := @new_rank + 1')
    end

    #update ranks metrics
    ChallengeData.insert challengers.select("'Challenger', challengers.id, 1, Now(), challengers.rank")

  end


  #function to set handicap values
  def update_handicap
    if handicap_type == 'None'
      challengers.update_all('challengers.handicap = 1.0')
    else
      challengers.send(handicap_options_hash[:join_option]).update_all(handicap_options_hash[:handicap_query])
    end
  end

  #generates a new invite code
  def generate_invite_code
    self.invite_code = SecureRandom.hex(3)
  end
end
