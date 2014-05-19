Ember.Inflector.inflector.irregular('ship', 'ships');
TheSkyMap.Ship = DS.Model.extend(
  name: DS.attr("string")
  desc: DS.attr("string")
  attack: DS.attr("number")
  speed: DS.attr("number")
  health: DS.attr("number")
  quadrant: DS.belongsTo('quadrant')
)
