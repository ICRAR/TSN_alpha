class BoincProfile < BoincPogsModel
  self.table_name = 'profile'
  belongs_to :boinc_remote_user, foreign_key: 'userid'

  #formats a markdown description from the 2 BOINC bbcode fields
  def description
    desc = ''
    desc << "### My personal background:\r\n"
    desc << self.r1.bbcode_to_md(true, extra_tags)
    desc << "\r\n"
    desc << "### My opinions about theSkyNet:\r\n"
    desc << self.r1.bbcode_to_md(true, extra_tags)
    desc << "\r\n"

  end

  def bb_code_to_lower(s)
    s.gsub /\[([^\]]+)\]/ do |f|
      f.downcase
    end
  end
  def r1
    self.bb_code_to_lower self.response1
  end
  def r2
    self.bb_code_to_lower self.response2
  end

  def extra_tags
    {
      :size => {
        :html_open => '', :html_close => '',
        :description => 'Change the size of the text',
        :example => '[size=32]This is 32px[/size]',
        :allow_tag_param => true, :allow_tag_param_between => false,
        :tag_param => /(\d*)/,
        :tag_param_tokens => [{:token => :size}]},
    }
  end
end
