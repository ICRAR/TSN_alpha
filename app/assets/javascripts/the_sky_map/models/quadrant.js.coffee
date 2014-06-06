Ember.Inflector.inflector.irregular('quadrant', 'quadrants');
TheSkyMap.Quadrant = DS.Model.extend(
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
  total_score: DS.attr("number")
  total_income: DS.attr("number")
  num_bases: DS.attr("number")
  desc: DS.attr("string")
  color: DS.attr("string")
  player: DS.belongsTo('player')
  ships: DS.hasMany('ship',{ async: true })
  has_ships: ( ->
    @get('ships').get('length') > 0
  ).property('ships.@each.isLoaded')
  bases: DS.hasMany('base',{ async: true })
  has_bases: ( ->
    @get('bases').get('length') > 0
  ).property('bases.@each.isLoaded')

)

