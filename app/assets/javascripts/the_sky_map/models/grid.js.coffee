Ember.Inflector.inflector.irregular('grid', 'grids');
TheSkyMap.Grid = DS.Model.extend(
  name: DS.attr("string")
  x: DS.attr("number")
  y: DS.attr("number")
  z: DS.attr("number")
  edge: DS.attr("boolean")
)

