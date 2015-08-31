class Hdf5PixelType < PogsModel
  self.table_name = 'hdf5_pixel_type'
  attr_accessible :argument_name, :description, as: [:admin]
  def readonly?
    return false
  end

  def name_for_form
    "<abbr title=\"#{argument_name}\">#{description}</abbr>".html_safe
  end
end
