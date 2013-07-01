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

  def send_report(boinc_id)

    #check if user has already requested a report
    #a user can only request report a minutes
    db_connection = connection.instance_variable_get(:@connection)
    query = "SELECT * FROM `magphys`.`docmosis_task` WHERE `userid` = #{boinc_id};"
    user_check_result = db_connection.query(query,:as => :hash)
    if user_check_result.any? {|u| u["create_time"] > 60.seconds.ago}
      return false

    else
      #otherwise send report
      #add user to task list and record task_id
      query = "INSERT INTO `docmosis_task` (userid) VALUES (#{boinc_id})"
      result = db_connection.query(query,:as => :hash)
      last_id = db_connection.last_id
      #add galaxy tasklist with task_id
      query = "INSERT INTO `docmosis_task_galaxy` (task_id,galaxy_id) VALUES (#{last_id},#{id})"
      result = db_connection.query(query,:as => :hash)

      #set user's task to status 1
      query = "UPDATE `docmosis_task` SET status=1 WHERE task_id=#{last_id}"
      result = db_connection.query(query,:as => :hash)

      return true
    end

  end

  #returns a image blob with the users area's added
  def color_image_user(user_id, colour)
    require 'RMagick'
    #get original image
    image_url = self.image_url(colour,nil)
    urlimage = open(image_url)
    image = Magick::ImageList.new.from_blob(urlimage.read)

    #load areas
    areas = GalaxyArea.areas(self.id, user_id)

    #apply areas
    drawing = Magick::Draw.new
    areas.each do |area|
      drawing.fill('white')
      drawing.fill_opacity(0.5)
      drawing.stroke_opacity(0)
      drawing.stroke_width(0)
      drawing.rectangle(area.top_x,area.top_y,area.bottom_x,area.bottom_y)
    end
    drawing.draw(image)

    #return blob
    image.to_blob


  end

end
