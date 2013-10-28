class Hdf5Request < PogsModel
  self.table_name = 'hdf5_request'
  attr_accessible :profile_id, :galaxy_id, :email, :link, :state, :feature_ids, :layer_ids,  as: [:admin, :default]
  def readonly?
    return false
  end

  before_validation :add_email
  def add_email
    if (self.email.nil? || self.email == '') && !profile_id.nil?
      self.email = self.profile.user.email
      self.save
    end
  end

  validate :has_feature?
  def has_feature?
    errors.add(:features, 'At least one feature must be selected.') if self.features.empty?
  end

  validate :has_layer?
  def has_layer?
    errors.add(:layers, 'At least one layer must be selected.') if self.layers.empty?
  end

  validate :galaxy_exists?
  def galaxy_exists?
    if galaxy_id.nil?
      errors.add(:galaxy_id, 'You must enter a galaxy ID.')
    elsif galaxy.nil?
      errors.add(:galaxy_id, 'You must enter a VALID galaxy ID.')
    end
  end

  validate :profile_exists?
  def profile_exists?
    if profile_id.nil?
      errors.add(:profile_id, 'You must enter a profile.')
    elsif profile.nil?
      errors.add(:profile_id, 'You must enter a VALID profile.')
    end
  end

  belongs_to :profile
  belongs_to :galaxy

  has_and_belongs_to_many :features,
                          class_name: "Hdf5Feature",
                          foreign_key: "hdf5_request_id",
                          association_foreign_key: "hdf5_feature_id",
                          join_table: "hdf5_request_feature"
  has_and_belongs_to_many :layers,
                          class_name: "Hdf5Layer",
                          foreign_key: "hdf5_request_id",
                          association_foreign_key: "hdf5_layer_id",
                          join_table: "hdf5_request_layer"

  def current_state
    case self.state
      when 0
        'Unprocessed'
      when 1
        'Processing'
      when 2
        'Processed'
      else
        'Unknown'
    end
  end


  rails_admin do
    field :id
    field :profile do
      help 'Required'
    end
    field :galaxy_id do
      help 'Required'
    end
    field :email do
      help 'Default email for user will be used if this is left blank.'
    end
    field :link
    field :state
    field :features do
      help 'At least one must be selected.'
    end
    field :layers do
      help 'At least one must be selected.'
    end
    configure :block_grid_associations do
      visible(false)
    end
  end

end
