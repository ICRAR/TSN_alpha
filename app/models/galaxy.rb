require 'voruby/votable/votable'
require 'voruby/votable/1.1/votable'
include VORuby

class Galaxy < PogsModel
  self.table_name = 'galaxy'

  def self.num_current
    where{((pixels_processed/pixel_count) > 0) & ((pixels_processed/pixel_count) < 1)}
    .count
  end

  def self.find_by_user_id(user_id)
    uniq.joins("INNER JOIN area ON galaxy.galaxy_id = area.galaxy_id
            INNER JOIN area_user ON area.area_id = area_user.area_id")
    .where("area_user.userid = #{user_id}")
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
  #returns a image blob with the users area's added
  def color_image_user(user_id, colour, scale = false, size=500)
    require 'RMagick'
    #get original image
    image_url = self.image_url(colour)
    urlimage = open(image_url)
    image = Magick::ImageList.new.from_blob(urlimage.read)

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
      drawing.rectangle(area.top_x,area.top_y,area.bottom_x,area.bottom_y)
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
