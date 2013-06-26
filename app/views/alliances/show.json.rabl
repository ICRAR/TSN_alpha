object @alliance
attributes :id, :ranking, :credit, :desc, :tag_list
node(:name) { |a| a.name.titleize}
node(:current_size) {@alliance.members.size}
node(:total_size) {@total_members}

child @members => :members do
  node(:id) {|m| m.profile.id}
  attribute :credits, :credit_contributed
  node(:name) {|m| m.profile.name}
  node(:url) {|m| profile_url(m.profile,:format => :json)}
  node(:is_current_member) {|m| m.leave_date == nil ? true : false}
end
node(:paginate_members) do
  paginate_json @members
end