Ember.Inflector.inflector.irregular('base', 'bases');
TheSkyMap.Base = TheSkyMap.Actionable.extend(
  name: DS.attr("string")
  desc: DS.attr("string")
  type: DS.attr("string")
  mine: DS.attr("boolean")
  hostile: DS.attr("boolean")
  quadrant: DS.belongsTo('quadrant')
  game_actions_available: DS.attr('raw')
)
