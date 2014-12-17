TheSkyMap.Actionable = DS.Model.extend(
  actions: DS.hasMany('action')
)
TheSkyMap.Action = DS.Model.extend(
  action: DS.attr("string")
  skippable: DS.attr("boolean")
  current_state: DS.attr("string")
  completed_at: DS.attr("string")
  run_at_time: DS.attr("number")
  queued_at_time: DS.attr("number")
  actionable: DS.belongsTo('actionable', { polymorphic: true})
  options: DS.attr('raw')
)
