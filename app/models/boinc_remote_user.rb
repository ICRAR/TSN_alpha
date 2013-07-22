class BoincRemoteUser < BoincPogsModel
  # attr_accessible :title, :body
  self.table_name = 'user'

  def self.auth(login, password)
    user = self.where{(email_addr == login) | (name == login)}.first
    return false if user.nil?
    pwd_hash = Digest::MD5.hexdigest(password+login.downcase)
    return pwd_hash == user.passwd_hash ? user : false
  end

end