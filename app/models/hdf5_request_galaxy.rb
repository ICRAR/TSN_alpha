class Hdf5RequestGalaxy < PogsModel
  self.table_name = 'hdf5_request_galaxy'
  attr_accessible :link, :state, as: [:admin]
  belongs_to :galaxy
  belongs_to :hdf5_request
  def readonly?
    return false
  end

  def link_valid?
    return false if link.nil? or link == ''
    return false if link_expires_at < Time.now
    true
  end

  def link_url
    return "" if link.nil? or link == ''
    if self.link[/\Ahttp:\/\//] || self.link[/\Ahttps:\/\//]
      self.link
    else
      "http://#{self.link}"
    end
  end

  def current_state
    case self.state
      when 0
        'Unprocessed'
      when 1
        'Processing'
      when 2
        'Processed'
      when 3
        'Failed'
      else
        'Unknown'
    end
  end

end
