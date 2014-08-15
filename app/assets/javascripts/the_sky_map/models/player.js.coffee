Ember.Inflector.inflector.irregular('player', 'players');
TheSkyMap.Player = TheSkyMap.Actionable.extend(
  name: DS.attr("string")
  rank: DS.attr("number")
  total_score: DS.attr("number")
  profile_id: DS.attr("number")
  bases: DS.hasMany('base',{ async: true })
  ships: DS.hasMany('ship',{ async: true })
  quadrants: DS.hasMany('quadrant',{ async: true })
)
