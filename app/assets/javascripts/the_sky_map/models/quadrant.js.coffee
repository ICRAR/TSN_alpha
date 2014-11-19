Ember.Inflector.inflector.irregular('quadrant', 'quadrants');
TheSkyMap.Quadrant = DS.Model.extend(
  name: DS.attr("string")
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
  total_score: DS.attr("number")
  total_income: DS.attr("number")
  num_bases: DS.attr("number")
  desc: DS.attr("string")
  player: DS.belongsTo('player')
  ships: DS.hasMany('ship', { async: true })
  location: DS.attr('raw')
  galaxy_id: DS.attr("number")
  thumbnail_src: DS.attr("string")
  has_ships: ( ->
    @get('_data.ships.length') > 0
  ).property('_data.ships.length')
  bases: DS.hasMany('base', { async: true })
  has_bases: ( ->
    @get('_data.bases.length') > 0
  ).property('_data.bases.length')

)

