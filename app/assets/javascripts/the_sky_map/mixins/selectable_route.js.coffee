TheSkyMap.SelectableRoute = Ember.Mixin.create
  afterModel: (model,transition) ->
    @controllerFor('board').set('selected_quadrant', model.get('location'))
  deactivate: () ->
    @controllerFor('board').set('selected_quadrant', {x: -1,y: -1, z: -1})