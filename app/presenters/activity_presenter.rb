class ActivityPresenter < SimpleDelegator
  attr_reader :activity, :klass

  def initialize(activity, view)
    super(view)
    @activity = activity
    @klass = activity.trackable_type.nil? ? 'undefined' : activity.trackable_type.underscore
  end

  def render_activity
    locals = {activity: activity, presenter: self}
    locals[:type] = activity.is_single? ? "single" : "multi"
    locals[:klass] = klass
    locals[:action] = activity.action

    render "shared/activity", locals
  end
end