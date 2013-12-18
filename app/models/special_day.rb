class SpecialDay < ActiveRecord::Base
  attr_accessible :name, :start_day, :start_month, :start_date,
                  :end_day, :end_month, :end_date, :annual,
                  :locale, :url_code, :url_code_only, :features, as: [:admin]
  validates_presence_of :name, :url_code
  validates_uniqueness_of :name, :url_code
  validate :validate_dates
  def validate_dates
    unless url_code_only == true
      if annual == true
        #start and end dates show be nil
        errors[:start_date] << "should be nil for annual day" unless start_date.nil?
        errors[:end_date] << "should be nil for annual day" unless end_date.nil?

        errors[:start_day]   << "should note be nil for non annual day" if start_day.nil?
        errors[:end_day]     << "should note be nil for non annual day" if end_day.nil?
        errors[:start_month] << "should note be nil for non annual day" if start_month.nil?
        errors[:end_month]   << "should note be nil for non annual day" if end_month.nil?
        unless start_day.nil? || end_day.nil? || start_month.nil? || end_month.nil?
          #start day+month should be before end data and month
          errors[:start_month] << "out of range" if start_month <= 0 || start_month > 12
          errors[:end_month] << "out of range" if end_month <= 0 || end_month > 12
          errors[:start_day] << "out of range" if start_day <= 0 || start_month > 31
          errors[:end_day] << "out of range" if end_day <= 0 || end_month > 31

          if start_month == end_month
            errors[:end_day] << "end day before start day in same month" unless start_day <= end_day
          else
            errors[:end_month] << "end month before start month" unless start_month < end_month
          end
        end
      else
        #start and end days and months show be nil
        errors[:start_day] << "should be nil for non annual day" unless start_day.nil?
        errors[:end_day] << "should be nil for non annual day" unless end_day.nil?
        errors[:start_month] << "should be nil for non annual day" unless start_month.nil?
        errors[:end_month] << "should be nil for non annual day" unless end_month.nil?

        errors[:end_date] << "should not be nil for non annual day" if end_date.nil?
        errors[:start_date] << "should not be nil for non annual day" if start_date.nil?
        unless end_date.nil?
          errors[:end_date] << "end date should be after start date" if end_date < start_date
        end
      end
    end
  end

  attr_accessible :logo, as: [:admin]
  has_attached_file :logo

  def self.active_days(params)
    t = Time.now
    possible_url_codes = params.select { |key, value| value == 'true' }.keys
    self.where{((annual == false) & (start_date <= t) & (end_date >= t)) |
               ((annual == true) &
                  (((start_month == t.month) & (start_day <= t.day)) | (start_month < t.month)) &
                  (((end_month == t.month) & (end_day >= t.day)) | (end_month > t.month))
               ) |
               (url_code.in possible_url_codes)}
  end

  def self.contains_feature(f)
    scoped.each do |day|
      return true if day.features_array.include? f
    end
    return false
  end

  def self.is_active(name)
    scoped.each do |day|
      return true if day.name == name
    end
    return false
  end

  def features_array
    CSV.parse(self.features).first
  end

  rails_admin do
    list do
      field :name
      field :features
      field :locale
      field :logo
      field :created_at
    end
    include_all_fields
    field :name
    field :logo
    field :annual do
      help 'Tick for events that reoccure annually, then enter start and end days and months. Only use, Start Date and End Date for once off events'
    end
    field :features do
      help 'List of features separated by commas ie "bats, snow"'
    end
  end
end
