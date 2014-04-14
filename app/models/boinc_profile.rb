class BoincProfile < BoincPogsModel
  self.table_name = 'profile'
  belongs_to :boinc_remote_user, foreign_key: 'userid'

  #formats a markdown description from the 2 BOINC bbcode fields
  def description
    desc = ''
    desc << "### My personal background:\r\n"
    desc << self.r1.bbcode_to_md
    desc << "\r\n"
    desc << "### My opinions about theSkyNet:\r\n"
    desc << self.r1.bbcode_to_md
    desc << "\r\n"

  end

  def bb_code_to_lower(s)
    s.gsub(/\[([^\]]+)\]/,"[#{$1.downcase}]")
  end
  def r1
    self.bb_code_to_lower self.response1
  end
  def r2
    self.bb_code_to_lower self.response2
  end
end
