Fabricator(:user) do
  username Fabricate.sequence(:name) { |i| "Name #{i}" }
  email { |attrs| "#{attrs[:username].parameterize}@exmaple.com"}
  password 'password'
  password_confirmation 'password'
  confirmed_at Time.now
end
Fabricator(:admin, from: :user) do
  admin true
end