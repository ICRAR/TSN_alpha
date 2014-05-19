# For more information see: http://emberjs.com/guides/routing/

TheSkyMap.Router.map ()->
  # @resource('posts')
  @route 'home', path: '/'
  @route 'name'
  @resource 'quadrants', {path: '/quadrants'}, () ->
    @route 'show', {path: '/:quadrant_id'}
  @resource 'ships', {path: '/ships'}, () ->
    @route 'show', {path: '/:ship_id'}
  @resource 'shout_boxes', {path: '/shout_boxes'}, () ->
    @route 'show', {path: '/:shout_id'}


TheSkyMap.ApplicationRoute = Ember.Route.extend
  actions:
    error: (reason) ->
      window.location.replace("/users/sign_in")  if reason instanceof TheSkyMap.UnauthorizedError

TheSkyMap.WithNameRoute = Ember.Route.extend
  renderTemplate: () ->
    @_super()
    @render 'name', {
      outlet: 'name'
      controller: 'name'
    }
    @render()
TheSkyMap.ShoutBoxesIndexRoute = TheSkyMap.WithNameRoute.extend
  model: ->
    this.store.find('shout_box')
TheSkyMap.ShoutBoxesShowRoute =TheSkyMap.WithNameRoute.extend
  model: (params) ->
    this.store.find('shout_box', params.shout_id)


TheSkyMap.QuadrantShowRoute = Ember.Route.extend
  model: (params)->
    this.store.find('quadrant', params.quadrant_id)


TheSkyMap.ShipShowRoute = Ember.Route.extend
  model: (params)->
    this.store.find('ship', params.ship_id)



