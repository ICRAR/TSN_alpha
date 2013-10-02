object  @notification
attributes :id, :body, :subject, :notified_object_id, :notified_object_type, :created_at
node(:is_read) {|n| n.is_read? @profile}