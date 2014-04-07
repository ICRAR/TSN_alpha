collection  @notifications
attributes :id, :subject, :created_at
node(:time_ago_string) {|n|
  distance_of_time_in_words(Time.now, n.created_at)
}
