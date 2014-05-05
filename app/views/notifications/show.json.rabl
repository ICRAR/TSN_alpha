object  @notification
attributes :id, :body, :subject, :notifier_id, :notifier_type, :created_at
node(:is_read) {|n| n.is_read?}