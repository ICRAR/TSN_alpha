Ember.Inflector.inflector.irregular('mini_quadrant', 'mini_quadrants');
TheSkyMap.MiniQuadrant = DS.Model.extend(
  name: DS.attr("string")
  colour: DS.attr("string")
  x: DS.attr("number")
  y: DS.attr("number")
  game_map_id: DS.attr("number")
  home: DS.attr("boolean")
  mine: DS.attr("boolean")
  hostile: DS.attr("boolean")
  unowned: DS.attr("boolean")
  explored: DS.attr("boolean")
  explored_fully: DS.attr("boolean")
  explored_partial: DS.attr("boolean")
  symbol: DS.attr("string")
  player_id: DS.attr("number")
  style: (() ->
      "background-color: #{@.get('colour')};"
    ).property('colour')
)

