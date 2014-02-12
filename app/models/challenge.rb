class Challenge < ActiveRecord::Base
  attr_accessible :name, :desc, :end_date, :start_date, :invite_only, :challenge_system, :challenger_type, :project, :manager_id, :started, :finished, :join_while_running,  as: [:admin]
  has_many :challengers
  belongs_to :manager, class_name: 'Profile'
  def self.not_hidden(admin = false)
    if admin
      self.scoped
    else
      where{hidden == false}
    end
  end


  def challenger_type_enum
    ['Profile', 'Alliance']
  end
  def challenge_system_enum
    ['Credit', 'RAC']
  end
  def project_enum
    ['All']
  end

  validates_presence_of :name, :desc, :start_date, :end_date, :challenger_type, :challenge_system, :project, :manager_id
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

  def joinable?
    !invite_only? && ((running? && join_while_running?) || !started)
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

  def join(entity)
    #double check entity is allowed to join
    return false unless self.joinable?
    #create new challenger object
    new_challenger = Challenger.new(
        challenge: self,
        entity: entity
    )

    #fix for join whilst running

    if new_challenger.valid?
      return new_challenger.save
    else
      return false
    end


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
      self.send "start_#{self.challenger_type}_#{self.challenge_system}".downcase.to_sym

      self.update_stats
      Challenge.delay({run_at: 30.minutes.from_now}).update_stats(self.id)
      self.started = true
      self.finished = false
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
    if c.end_date > 30.minutes.from_now
      c.next_update_time = next_update
      c.save
      Challenge.delay({run_at: next_update}).update_stats(c.id)
    else
      c.next_update_time = end_date
      c.save
    end
  end

  def update_stats
    return false unless self.running?
    #update save value
    self.send "update_save_#{self.challenger_type}_#{self.challenge_system}".downcase.to_sym
    #update score
    challengers.update_all('challengers.score = challengers.save_value - challengers.start')
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


  #functions must take the form of [update | start]_[challenger_type]_[challenge_system]
  def update_save_alliance_credit
    #update scores
    challengers.joins_alliance.update_all('challengers.save_value = a.credit')
  end
  def start_alliance_credit
    #update scores
    challengers.joins_alliance.update_all('challengers.start = a.credit')
  end

  def update_save_profile_credit
    #update scores
    challengers.joins_profile_with_gsi.update_all('challengers.save_value = g.total_credit')
  end
  def start_profile_credit
    #update scores
    challengers.joins_profile_with_gsi.update_all('challengers.start = g.total_credit')
  end
  def update_save_alliance_rac
    #update scores
    challengers.joins_alliance.update_all('challengers.save_value = a.RAC')
  end
  def start_alliance_rac
    #update scores
    challengers.joins_alliance.update_all('challengers.start = a.RAC')
  end

  def update_save_profile_rac
    #update scores
    challengers.joins_profile_with_gsi.update_all('challengers.save_value = g.recent_avg_credit')
  end
  def start_profile_rac
    #update scores
    challengers.joins_profile_with_gsi.update_all('challengers.start = g.recent_avg_credit')
  end
end
