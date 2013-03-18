class BoincStatsItem < ActiveRecord::Base
  extend GraphiteUrlModule
  include GraphiteUrlModule

  attr_accessible :boinc_id, :credit, :RAC, :rank
  scope :connected, where('general_stats_item_id IS NOT NULL')
  belongs_to :general_stats_item

  def render_credit_graph_url
    simple_graph("stats.gauges.TSN_dev.boinc.users.#{boinc_id}.credit")
  end
  def self.render_credit_total_url
    simple_graph("stats.gauges.TSN_dev.boinc.stat.total_credit")
  end
  def self.render_total_users_url
    simple_graph("stats.gauges.TSN_dev.boinc.stat.active_users")
  end
  def self.render_tflops_url
    graph_url('scale(stats.gauges.TSN_dev.boinc.stat.total_rac%2C0.000005)',400,250,'-7days','Approx_Current_Tflops')
  end

  def self.find_by_boinc_auth(email, password)
    query = {email_addr: email, passwd_hash: Digest::MD5.hexdigest(password+email.downcase)}.to_query
    url = APP_CONFIG['boinc_url'] + "lookup_account.php?"+ query
    remote_file = open(url)
    xml = Nokogiri::XML(remote_file)

    if xml.xpath("//error").empty?
      auth = xml.at_xpath("//account_out/authenticator").text

      query = {account_key: auth}.to_query
      url = APP_CONFIG['boinc_url'] + "am_get_info.php?"+ query
      remote_file = open(url)
      xml = Nokogiri::XML(remote_file)

      id = xml.at_xpath('//id').text.to_i

      item = self.where(boinc_id: id).first
      if item.general_stats_item_id == nil
        return item
      else
        return false
      end
    else
      #ToDo   Add error to boinc user auth
      return false
    end

  end
end
