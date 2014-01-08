object false
child @profile => :profile do
  attributes :id, :name
end
if @by_sets
  child @trophies => 'trophy sets' do
    attributes :id, :name
    child :profile_trophies => 'trophies' do
      attributes :id, :title
      node(:credits) {|t| t.show_credits(@trophy_ids)}
    end
  end
else
  child @trophies => 'trophies' do
    attributes :id, :title
    node(:credits) {|t| t.show_credits(@trophy_ids)}
  end
end
