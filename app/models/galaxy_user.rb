class GalaxyUser < PogsModel
  self.table_name = 'galaxy_user'
  belongs_to :galaxies

  def self.profiles
    boinc_ids = group(:userid).pluck(:userid)
    Profile.joins{general_stats_item.boinc_stats_item}.where{boinc_stats_items.boinc_id.in boinc_ids}
  end

  def self.with_at_least_galaxies(num)
    having('count(*) >= ?',num).group(:userid)
  end

  def self.profiles_in_batches(num, profiles, &blk)
    ids_all = GalaxyUser.with_at_least_galaxies(num).pluck(:userid)
    ids_all.each_slice(1000) do |ids_batch|
      ps = profiles.joins{general_stats_item.boinc_stats_item}.where{boinc_stats_items.boinc_id.in ids_batch}
      blk.call(ps)
    end
  end

  def self.test
    GalaxyUser.with_at_least_galaxies(1000).my_batch(batch_size: 200, offset: 0) do |batch|
      puts batch.pluck(:userid).to_json
    end
  end

end