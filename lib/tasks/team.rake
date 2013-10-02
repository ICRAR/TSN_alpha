namespace :teams do

  desc "list all team/alliance matches"
  task :find_matches => :environment do
    a = Alliance.all
    t = PogsTeam.where{nusers > 0}
    th = Hash[*t.map{|i| [i["name"], i]}.flatten]

    match = []
    a.each do |i|
      team = th[i.name]
      unless team.nil?
        match << {:alliance => i,:team => team}
      end
    end
    outs = ''
    puts "found #{match.size} matches"
    match.each do |m|
      a_l = m[:alliance].leader
      t_l_id = m[:team].userid
      t_l = BoincRemoteUser.find t_l_id

      out = "Found #{m[:alliance].name}"
      out << ", Alliance Leader:  #{a_l.name} (#{a_l.user.email})" unless a_l.nil?
      out << ", Team Leader:  #{t_l.name} (#{t_l.email_addr})" unless t_l.nil?

      outs << out
      outs << "\n"

      puts out
    end

    new_match = []
    match.each do |m|
      a_l = m[:alliance].leader
      t_l_id = m[:team].userid
      t_l = BoincRemoteUser.find t_l_id
      if  !a_l.nil? && !t_l.nil? && a_l.user.email != t_l.email_addr
        new_match << m[:alliance].name
      end
    end
  end

end