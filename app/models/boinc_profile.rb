class BoincProfile < BoincPogsModel
  self.table_name = 'profile'
  belongs_to :boinc_remote_user, foreign_key: 'userid'

  #formats a markdown description from the 2 BOINC bbcode fields
  def description
    desc = ''
    unless self.response1.nil? || self.response1 == ''
      desc << "### My personal background:\r\n"
      desc << self.r1.bbcode_to_md(true, extra_tags)
      desc << "\r\n"
    end
    unless self.response2.nil? || self.response2 == ''
      desc << "### My opinions about theSkyNet:\r\n"
      desc << self.r2.bbcode_to_md(true, extra_tags)
      desc << "\r\n"
    end
    desc
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
      :img => {
        :html_open => "\n !(%between%)", :html_close => "\n",
        :description => 'Image',
        :example => '[img]http://www.google.com/intl/en_ALL/images/logo.gif[/img].',
        :only_allow => [],
        :require_between => true,
        :allow_tag_param => true, :allow_tag_param_between => false,
        :tag_param => /^(\d*)x(\d*)$/,
        :tag_param_tokens => [{:token => :width, :prefix => 'width="', :postfix => '" ' },
                              { :token => :height,  :prefix => 'height="', :postfix => '" ' } ],
        :tag_param_description => 'The image parameters \'%param%\' are incorrect, <width>x<height> excepted'},
      :url => {
        :html_open => '[%between%](%url%)', :html_close => '',
        :description => 'Link to another page',
        :example => '[url]http://www.google.com/[/url].',
        :only_allow => [],
        :require_between => true,
        :allow_tag_param => true, :allow_tag_param_between => false,
        :tag_param => /^((((http|https|ftp|irc):\/\/)|\/).+)$/, :tag_param_tokens => [{ :token => :url }],
        :tag_param_description => 'The URL should start with http:// https://, ftp:// or /, instead of \'%param%\'' },
    }
  end
end
