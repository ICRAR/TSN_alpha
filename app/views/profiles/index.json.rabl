object false
child(@profiles) do
  attributes :id, :name, :rank, :credits, :rac
  node(:allaince_name) {|p|
    p.alliance ? p.alliance.name : 'Flying Solo'
  }
  node(:allaince_link) {|p|
    p.alliance ? alliance_url(p.alliance,:format => :json) : 'Null'
  }
  node(:profile_link) { |p| profile_url(p,:format => :json)}

end
node(:paginate) do
  paginate_json @profiles
end

