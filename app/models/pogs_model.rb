#uses an external database connect and forces the models to be read only
class PogsModel < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "pogs_db"

  # Prevent creation of new records and modification to existing records
  def readonly?
    return true
  end

  # Prevent objects from being destroyed
  def before_destroy
    raise ActiveRecord::ReadOnlyRecord
  end
  def self.delete_all
    raise ActiveRecord::ReadOnlyRecord
  end
  def delete
    raise ActiveRecord::ReadOnlyRecord
  end
end