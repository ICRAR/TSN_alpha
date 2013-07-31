object false
child @profile => :profile do
  attributes :id, :name
end

child @trophies => 'trophy sets' do
  attributes :id, :name
  child :profile_trophies => 'trophies' do
    attributes :id, :title
  end
end