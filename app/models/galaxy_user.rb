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

  def self.profiles_in_batches_by_count(num, profiles,users_array = nil,&blk)
    if users_array.nil?
      ids_all = GalaxyUser.with_at_least_galaxies(num).pluck(:userid)
    else
      ids_all = GalaxyUser.users_from_array(num, users_array)
    end
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

  def self.all_users_count
    query = GalaxyUser.group(:userid).select{userid}.select{count('*').as 'count'}
    GalaxyUser.connection.select_all(query)
  end
  def self.users_from_array(count, users_array)
    users_array ||= GalaxyUser.all_users_count
    users_array.select{|x| x['count'] > count}.map{|x| x['userid']}
  end
end