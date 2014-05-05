collection @profiles
attributes :id, :name
node(:alliance_name) {|p|
  p.alliance ? p.alliance.name : 'Flying Solo'
}
node(:avatar_url) { |p| p.avatar_url(32)}
node(:path) {|p| profile_path(p.id)}