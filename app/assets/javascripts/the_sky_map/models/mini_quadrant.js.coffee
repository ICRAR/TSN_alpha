Ember.Inflector.inflector.irregular('mini_quadrant', 'mini_quadrants');
TheSkyMap.MiniQuadrant = DS.Model.extend(
  name: DS.attr("string")
  x: DS.attr("number")
  y: DS.attr("number")
  z: DS.attr("number")
  home: DS.attr("boolean")
  mine: DS.attr("boolean")
  hostile: DS.attr("boolean")
  unowned: DS.attr("boolean")
  explored: DS.attr("boolean")
  explored_fully: DS.attr("boolean")
  explored_partial: DS.attr("boolean")
  color: DS.attr("string")
  symbol: DS.attr("string")
  player_id: DS.attr("number")
)

