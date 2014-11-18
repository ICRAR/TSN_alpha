require 'voruby/votable/votable'
require 'voruby/votable/1.1/votable'
include VORuby

class Galaxy < PogsModel
  self.table_name = 'galaxy'

  has_many :areas, class_name: "GalaxyArea"
  has_many :galaxy_users

  has_and_belongs_to_many :tags,
                          class_name: "GalaxyTag",
                          foreign_key: "galaxy_id",
                          association_foreign_key: "tag_id",
                          join_table: "tag_galaxy"

  scope :completed, where{(pixels_processed/pixel_count) >= 1.0}

  def self.search_options (options)
    search_options = []
    search_options << "galaxy.name LIKE \"%#{Mysql2::Client.escape(options[:name])}%\"" if options[:name] != nil  && options[:name] != ''
    search_options << "galaxy.galaxy_type = \"#{Mysql2::Client.escape(options[:galaxy_type])}\"" if options[:galaxy_type] != nil && options[:galaxy_type] != ''
    search_options << "galaxy.galaxy_id >= \"#{Mysql2::Client.escape(options[:id_from])}\"" if options[:id_from] != nil && options[:id_from] != ''
    search_options << "galaxy.galaxy_id <= \"#{Mysql2::Client.escape(options[:id_to])}\"" if options[:id_to] != nil && options[:id_to] != ''
    search_options << "galaxy.ra_cent >= \"#{Mysql2::Client.escape(options[:ra_from])}\"" if options[:ra_from] != nil && options[:ra_from] != ''
    search_options << "galaxy.ra_cent <= \"#{Mysql2::Client.escape(options[:ra_to])}\"" if options[:ra_to] != nil && options[:ra_to] != ''
    search_options << "galaxy.dec_cent >= \"#{Mysql2::Client.escape(options[:dec_from])}\"" if options[:dec_from] != nil && options[:dec_from] != ''
    search_options << "galaxy.dec_cent <= \"#{Mysql2::Client.escape(options[:dec_to])}\"" if options[:dec_to] != nil && options[:dec_to] != ''
    search_options = search_options.join(' AND ')

    galaxies = where(search_options)
    if options[:tag] != nil && options[:tag] != ''
      search_query = options[:tag]
      galaxies = galaxies.joins{tags}.where{tag.tag_text == search_query}
    end

    galaxies
  end

  def self.num_current
    where{status_id == 0}.count
  end

  def self.find_by_user_id(user_id)
    joins{galaxy_users}.where{galaxy_users.userid == user_id}
  end
  def self.find_by_user_id_last(user_id)
    #find_by_user_id(user_id).last
    joins("INNER JOIN area ON galaxy.galaxy_id = area.galaxy_id
            INNER JOIN area_user ON area.area_id = area_user.area_id")
    .where("area_user.userid = ?",user_id )
    .order("`area_user`.`areauser_id` DESC")
    .limit(1).first
  end

  #returns an active relations object containing the profiles of all people who worked on this galaxy
  def user_ids
    galaxy_users.pluck(:userid)
  end
  def profiles
    boinc_ids = self.user_ids
    profiles = Profile.joins{general_stats_item.boinc_stats_item}.where{boinc_stats_items.boinc_id.in boinc_ids}
  end



  def thumbnail_url
    APP_CONFIG['pogs_graphs_url'] + s3_name + "tn_colour_1.png"
  end
  def image_url(color)
    APP_CONFIG['pogs_graphs_url'] + s3_name + "colour_#{color}.png"
  end
  def parameter_image_url(parameter )
    APP_CONFIG['pogs_graphs_url'] + s3_name + "#{parameter}.png"
  end
  def self.parameter_image_options
    ['mu','m','ldust','sfr']
  end
  def s3_name
    "#{name}__#{run_id}__#{galaxy_id}/"
  end

  def label(color)
    GalaxyImageFilter.label(id,color)
  end

  def more_info_url
    "http://ned.ipac.caltech.edu/cgi-bin/objsearch?objname=#{name}&extend=no&hconst=73&omegam=0.27&omegav=0.73&corr_z=1&out_csys=Equatorial&out_equinox=J2000.0&obj_sort=RA+or+Longitude&of=pre_text&zv_breaker=30000.0&list_limit=5&img_stamp=YES"
  end

  def per_complete
    ((self.pixel_count == 0 || self.pixels_processed == 0) ? '0.00' : (self.pixels_processed*100.0/self.pixel_count).round(2).to_s)
  end

  def send_report(boinc_id)

    #check if user has already requested a report
    #a user can only request 5 reports at time
    boinc_item = BoincStatsItem.find_by_boinc_id(boinc_id)
    if boinc_item.nil? || boinc_item.get_report_count > 4
      return false

    else
      #otherwise send report
      boinc_item.inc_report_count
      Galaxy.delay.send_report(id,boinc_id)
      return true
    end

  end

  #connects to docmosis to generate a report then emails the report users email
  def self.send_report(galaxy_id, boinc_id)
    boinc_item = BoincStatsItem.find_by_boinc_id(boinc_id)
    galaxy_item = Galaxy.find(galaxy_id)
    if boinc_item.nil? || galaxy_item.nil?
      return false
    else

      #gets a hash of user details contain
      user_info = boinc_item.get_name_and_email
      galaxy_info = galaxy_item.get_galaxy_info

      template = 'Report.doc'
      output_name = 'DetailedUserReport.pdf'
      galaxy_data = {
          'galid' => "#{galaxy_item.name} (version #{galaxy_item.version_number})",
          #user images
          'pic1' => "image:base64:#{Base64.encode64(galaxy_item.color_image_user(boinc_id,1,true,500))}",
          'pic2' => "image:base64:#{Base64.encode64(galaxy_item.color_image_user(boinc_id,2,true,500))}",
          'pic3' => "image:base64:#{Base64.encode64(galaxy_item.color_image_user(boinc_id,3,true,500))}",
          'pic4' => "image:base64:#{Base64.encode64(galaxy_item.color_image_user(boinc_id,4,true,500))}",
          'pic1_label' => galaxy_item.label(1),
          'pic2_label' => galaxy_item.label(2),
          'pic3_label' => galaxy_item.label(3),
          'pic4_label' => galaxy_item.label(4),

          #galaxy info
          'gatype'           => galaxy_item.galaxy_type,
          'gars'             => galaxy_item.redshift.to_s,
          'gades'            => galaxy_info[:design],
          'gara_eqj2000'     => galaxy_info[:ra_eqj2000],
          'gadec_eqj2000'    => galaxy_info[:dec_eqj2000],
          'gara_eqb1950'     => galaxy_info[:ra_eqb1950],
          'gadec_eqb1950'    => galaxy_info[:dec_eqb1950]
      }
      #if they exist add the parameter image
      image_mu = galaxy_item.para_image_blob('mu')
      galaxy_data['pic5'] = "image:base64:#{Base64.encode64(image_mu)}" unless image_mu.nil?
      image_m = galaxy_item.para_image_blob('m')
      galaxy_data['pic6'] = "image:base64:#{Base64.encode64(image_m)}" unless image_m.nil?
      image_ldust = galaxy_item.para_image_blob('ldust')
      galaxy_data['pic7'] = "image:base64:#{Base64.encode64(image_ldust)}" unless image_ldust.nil?
      image_sfr = galaxy_item.para_image_blob('sfr')
      galaxy_data['pic8'] = "image:base64:#{Base64.encode64(image_sfr)}" unless image_sfr.nil?
      #set galaxy_data add to true if at least one of the images is not nil
      galaxy_data['add'] = true if (!image_mu.nil? ||  !image_m.nil? || !image_ldust.nil? || !image_sfr.nil?)


      data = {
          'user' => user_info[:name],
          'date' => Time.now,
          'galaxy' => galaxy_data
      }

      doc = Docmosis.new(
          :template => template,
          :output_name => output_name,
          :data => data,
          :email => user_info[:email]
      )
      if doc.email_pdf
        boinc_item.dec_report_count
        true
      else
        false
      end
    end
  end
  #returns a iamge blob for the parameter image or false otherwise
  def para_image_blob(par)
    url = self.parameter_image_url(par)
    begin
      response = RestClient.get(url)
      if response.code == 200
        return response.to_s
      else
        return nil
      end
    rescue Exception => e
      Rails.logger.error e.message
      return nil
    end
  end
  #inverts y coordiante
  def fix_y(y)
    fixed = [self.dimension_y-y,0].max
    [self.dimension_y,fixed].min
  end
  #returns a image blob with the users area's added
  def color_image_user(user_id, colour, scale = false, size=500)
    require 'RMagick'
    begin
       #get original image
      image_url = self.image_url(colour)
      urlimage = open(image_url)
      image = Magick::ImageList.new.from_blob(urlimage.read)
    rescue OpenURI::HTTPError
      #else make a new image
      image = Magick::Image.new(self.dimension_x,self.dimension_y) { self.background_color = "black" }
      image.format = 'png'
    end

    #load areas
    areas = GalaxyArea.areas(self.id, user_id)
    return image.to_blob if areas.size == 0
    #apply areas
    drawing = Magick::Draw.new
    areas.each do |area|
      drawing.fill('white')
      drawing.fill_opacity(0.5)
      drawing.stroke_opacity(0)
      drawing.stroke_width(0)
      drawing.rectangle(area.top_x,fix_y(area.top_y),area.bottom_x,fix_y(area.bottom_y))
    end
    drawing.draw(image)

    #return blob
    if scale == true
      max_size = [image.rows,image.columns].max
      scale_factor = size.to_f/max_size.to_f
      image = image.scale(scale_factor) unless scale_factor >= 1
    end
    image.to_blob


  end

  #generates a new image mosaic. the mosaic is a 4x4 grid of the 14 most recent completed galaxy images + theSkyNet Logo
  def self.generate_image_mosaic(file_name, cols =5 , rows =3, dim = 200)
    require 'RMagick'
    galaxies = Galaxy.completed.last(cols*rows)

    #new image
    image_list = Magick::ImageList.new
    page = Magick::Rectangle.new(0,0,0,0)

    #insert galaxy images
    count = 0
    galaxies.each do |galaxy|
      #load parameter image for galaxy
      puts "loading image #{count}:"
      galaxy_param = Galaxy.parameter_image_options.sample
      galaxy_image_url = galaxy.parameter_image_url(galaxy_param)
      urlimage = open(galaxy_image_url)
      galaxy_image = Magick::ImageList.new.from_blob(urlimage.read)

      #scale and crop to dim
      galaxy_image.resize_to_fit!(dim)
      puts "adding image #{count}:"

      #add text to image
      text = "#{galaxy.name} (#{galaxy_param})"
      puts "adding text: #{text}"
      draw = Magick::Draw.new
      draw.fill = 'White'
      draw.font_family = 'helvetica'
      font_size = (25 * dim / 300).to_i
      draw.pointsize = font_size
      draw.gravity = Magick::SouthGravity
      draw.annotate(galaxy_image, 0,0,0,10, text) {
        self.stroke = 'black'
        self.stroke_width = 3
      }
      draw.annotate(galaxy_image, 0,0,0,10, text) {
        self.stroke = 'none'
      }


      #add to list
      image_list << galaxy_image.cur_image
      #update position information
      x_cor = (count % cols).to_i * dim
      y_cor = (count / cols).to_i * dim
      page.x = x_cor
      page.y = y_cor
      image_list.page = page
      count = count + 1
    end

    #add logo
    logo_file_name = Rails.root.join('app','assets','images','logo_for_mosaic.png')
    logo_image = Magick::ImageList.new(logo_file_name)
    image_list << logo_image.resize_to_fit(dim*5,dim)
    x_cor = 0
    y_cor = (rows) * dim
    page.x = x_cor
    page.y = y_cor
    image_list.page = page

    #add info text
    info_font_size = (30 * dim / 300).to_i
    info_text_image = Magick::Image.new(dim*5,info_font_size*2) { self.background_color = "black" }
    info_draw = Magick::Draw.new
    info_text = "The data in this image was generated by the work of 1000 computers dontated by 500 users!"
    info_draw.fill = 'White'
    info_draw.font_family = 'helvetica'
    info_draw.pointsize = info_font_size
    info_draw.gravity = Magick::SouthGravity
    info_draw.annotate(info_text_image, 0,0,0,10, info_text) {
      self.stroke = 'black'
      self.stroke_width = 3
    }
    info_draw.annotate(info_text_image, 0,0,0,10, info_text) {
      self.stroke = 'none'
    }
    image_list << info_text_image
    x_cor = 0
    y_cor = (rows+1) * dim -1
    page.x = x_cor
    page.y = y_cor
    image_list.page = page

    #generate_mosaic
    mosaic = image_list.mosaic

    #add gridlines
    draw = Magick::Draw.new
    draw.stroke('grey')
    draw.stroke_width(1)
    draw.fill_opacity(0)
    #add cols
    (1..(cols-1)).each do |col|
      draw.line(col*dim,0,col*dim,rows*dim)
    end
    #add rows
    (1..(rows)).each do |row|
      draw.line(0,row*dim,cols*dim,row*dim)
    end
    draw.draw(mosaic)

    #finally save the image to file_name

    return mosaic

  end

  #searchs the NED and HyperLeda databases for the galaxy data using VOTable.
  def get_galaxy_info
    return_hash = {}
    #removes the last charcture of the name if its lower case, see Kevin for reason
    name = self.name[-1].match(/\p{Lower}/).nil? ? self.name : self.name[0..-2]

    #ned
    begin

      votable = get_vo_table('http://ned.ipac.caltech.edu/cgi-bin/objsearch',
                                {
                                  :expand => 'no',
                                  :objname => name,
                                  :of => 'xml_main'
                                }
      )
      return_hash[:design] = votable_find_value(votable,'Object Name')
      raise "Object not found in remote VOtable database" if return_hash[:design].nil?
      votable = get_vo_table('http://ned.ipac.caltech.edu/cgi-bin/objsearch',
                                {
                                    :expand => 'no',
                                    :objname => name,
                                    :of => 'xml_posn'
                                }
      )
      return_hash[:ra_eqj2000] = votable_find_value(votable,'pos_ra_equ_J2000_d')
      return_hash[:dec_eqj2000] = votable_find_value(votable,'pos_dec_equ_J2000_d')
      return_hash[:ra_eqb1950] = votable_find_value(votable,'pos_ra_equ_B1950_d')
      return_hash[:dec_eqb1950] = votable_find_value(votable,'pos_dec_equ_B1950_d')
      return return_hash
    rescue Exception => e
      Rails.logger.error e.message
    end

    #if NED failed try HyperLeda
    begin
      votable = get_vo_table('http://leda.univ-lyon1.fr/G.cgi',
                                {
                                    :n => 101,
                                    :c => 'o',
                                    :o => name,
                                    :a => 'x',
                                    :z => 'd'
                                }
      )
      return_hash[:design] = votable_find_value(votable,'design')
      raise "Object not found in remote VOtable database" if return_hash[:design].nil?
      votable = get_vo_table('http://leda.univ-lyon1.fr/G.cgi',
                               {
                                    :n => 113,
                                    :c => 'o',
                                    :o => name,
                                    :a => 'x',
                                    :z => 'd'
                                }
      )
      return_hash[:ra_eqj2000] = votable_find_value(votable,'alpha')
      return_hash[:dec_eqj2000] = votable_find_value(votable,'delta')
      return_hash[:ra_eqb1950] = 0
      return_hash[:dec_eqb1950] = 0
      return return_hash
    rescue Exception => e
      Rails.logger.error e.message
      return {}
    end

  end
end

def get_vo_table(url, params)
  response = RestClient.get(url, :params => params,:content_type => :xml, :timeout => 10)
  if response.code == 200
    return votable = VOTable.from_xml(response)
  else
    raise "Problem contacting VOTable Provider, #{url}"
  end
end
#hack to find values in a VOTable
def votable_find_value(votable,field_name)
  table = votable.resources.first.tables.first
  index = nil
  i = 0
  table.fields.each do |f|
    index = i if f.name == field_name
    i += 1
  end
  return table.data.format.trs.first.tds.to_a[index].value unless index.nil?
  return nil
end
