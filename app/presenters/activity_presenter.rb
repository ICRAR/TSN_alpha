class ActivityPresenter < SimpleDelegator
  attr_reader :activity, :klass

  def initialize(activity, view)
    super(view)
    @activity = activity
    @klass = activity.trackable_type.nil? ? 'undefined' : activity.trackable_type.underscore
  end

  def render_activity
    locals = {activity: activity, presenter: self, sub_path: partial_path}
    locals[klass.to_sym] = activity.trackable
    render "shared/activities/base", locals
  end
  def partial_path
    partial_paths.detect do |path|
      lookup_context.template_exists? path, nil, true
    end || raise("No partial found for activity in #{partial_paths}")
  end

  def partial_paths
    type = activity.is_single? ? "single" : "multi"
    [
        "shared/activities/#{klass}/#{type}_#{activity.action}",
        "shared/activities/#{klass}/#{activity.action}",
        "shared/activities/#{klass}",
        "shared/activities/activity"
    ]
  end
end