object false
child(@alliances) do
  attributes :id, :ranking, :credit
  node(:name) { |a| a.name}
  node(:url) {|a| alliance_url(a,:format => :json)}

end
node(:paginate) do
  paginate_json @alliances
end
