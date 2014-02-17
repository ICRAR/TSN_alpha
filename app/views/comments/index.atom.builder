atom_feed do |feed|
  feed.title "theSkyNet Recent Comments"
  feed.updated @comments.maximum(:updated_at)
  @comments.each do |comment|
    feed.entry(comment,url: polymorphic_url(comment.commentable)) do |entry|
      title =comment.profile.name
      title << ' (Staff)' if comment.profile.user.admin?
      title << " posted on #{comment.commentable_name}"
      title << " #{distance_of_time_in_words(Time.now, comment.created_at)} ago."
      entry.title title
      entry.content markdown(comment.content), type: 'html'
      entry.author do |author|
        author.name comment.profile.name
        author.uri polymorphic_url(comment.profile)
      end
    end
  end
end

