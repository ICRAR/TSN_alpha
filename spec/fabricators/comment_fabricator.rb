Fabricator(:comment) do
  profile_id {Fabricate(:user).reload.profile.id}
  content {Faker::Lorem.paragraph(5) }
end

Fabricator(:comment_with_children, from: :comment) do
  transient :num_children
  after_save do |comment, transients|
    transients[:num_children].times do
      ch = transients[:num_children] - rand(0..3)
      ch = 0 if ch < 0
      Fabricate(:comment_with_children,
                profile_id: comment.profile_id,
                parent_id: comment.id,
                commentable: comment.commentable,
                num_children: ch
      )
    end
  end
end
