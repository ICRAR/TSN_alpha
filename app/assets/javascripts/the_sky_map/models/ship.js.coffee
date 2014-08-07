Ember.Inflector.inflector.irregular('ship', 'ships');
TheSkyMap.Ship = TheSkyMap.Actionable.extend(
  name: DS.attr("string")
  desc: DS.attr("string")
  attack: DS.attr("number")
  speed: DS.attr("number")
  remaining_health: DS.attr("number")
  max_health: DS.attr("number")
  mine: DS.attr("boolean")
  hostile: DS.attr("boolean")
  quadrant: DS.belongsTo('quadrant')
  player: DS.belongsTo('player')
  game_actions_available: DS.attr('raw')
)
