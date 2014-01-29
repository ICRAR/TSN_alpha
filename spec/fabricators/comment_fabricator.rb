Fabricator(:comment) do
  profile_id {Fabricate(:user).reload.profile.id}
  content {Faker::Lorem.paragraph(5) }
end
