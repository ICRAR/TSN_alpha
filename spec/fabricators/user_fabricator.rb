Fabricator(:user) do
  username { Fabricate.sequence(:user_name) { |i| "Name #{i}" } }
  email { |attrs| "#{attrs[:username].parameterize}@exmaple.com"}
  password 'password'
  password_confirmation 'password'
  confirmed_at Time.now
end
Fabricator(:admin, from: :user) do
  admin true
end
Fabricator(:user_with_credit,from: :user) do
  transient :credit
  transient :rank
  after_save do |user, transients|

    g = user.profile.general_stats_item
    g.total_credit = transients[:credit]
    g.rank = transients[:rank]
    g.save
  end
end