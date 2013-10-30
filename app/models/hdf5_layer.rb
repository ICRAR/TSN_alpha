class Hdf5Layer < PogsModel
  self.table_name = 'hdf5_layer'
  attr_accessible :argument_name, :description, as: [:admin]
  def readonly?
    return false
  end

  def name_for_form
    "<abbr title=\"#{argument_name}\">#{description}</abbr>".html_safe
  end
end
