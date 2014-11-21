Ember.Inflector.inflector.irregular('message', 'messages');
TheSkyMap.Message = DS.Model.extend(
  msg: DS.attr("string")
  created_at: DS.attr("string")
  created_at_int: DS.attr("number")
  quadrant_id: DS.attr("number")
  ack: DS.attr("boolean")
  #quadrant: DS.belongsTo('quadrant')
)
