class BoincProfile < BoincPogsModel
  self.table_name = 'profile'
  belongs_to :boinc_remote_user, foreign_key: 'userid'

  #formats a markdown description from the 2 BOINC bbcode fields
  def description
    desc = ''
    desc << "### My personal background:\r\n"
    desc << self.response1.bbcode_to_md
    desc << "\r\n"
    desc << "### My opinions about theSkyNet:\r\n"
    desc << self.response2.bbcode_to_md
    desc << "\r\n"

  end
end
