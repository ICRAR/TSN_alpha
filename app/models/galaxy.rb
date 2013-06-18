class Galaxy < PogsModel
  # attr_accessible :title, :body
  self.table_name = 'galaxy'

  def self.find_by_user_id(user_id)
    uniq.joins("INNER JOIN area ON galaxy.galaxy_id = area.galaxy_id
            INNER JOIN area_user ON area.area_id = area_user.area_id")
    .where("area_user.userid = #{user_id}")
  end

  def thumbnail_url(color = 1 )
    APP_CONFIG['pogs_graphs_url'] + "GalaxyThumbnailImage/#{id}/#{color}"
  end
  def image_url(color = 1, user_id)
    if user_id == nil
      APP_CONFIG['pogs_graphs_url'] + "GalaxyImage/#{id}/#{color}"
    else
      APP_CONFIG['pogs_graphs_url'] + "UserGalaxyImage/#{user_id}/#{id}/#{color}"
    end
  end
  def parameter_image_url(parameter )
    APP_CONFIG['pogs_graphs_url'] + "GalaxyParameterImage/#{id}/#{parameter}"
  end


  def more_info_url
    "http://ned.ipac.caltech.edu/cgi-bin/objsearch?objname=#{name}&extend=no&hconst=73&omegam=0.27&omegav=0.73&corr_z=1&out_csys=Equatorial&out_equinox=J2000.0&obj_sort=RA+or+Longitude&of=pre_text&zv_breaker=30000.0&list_limit=5&img_stamp=YES"
  end

end
