# For more information see: http://emberjs.com/guides/routing/

TheSkyMap.Router.map ()->
  # @resource('posts')
  @route 'home', path: '/'
  @route 'name'
  @resource 'quadrants', {path: '/quadrants'}, () ->
    @route 'show', {path: '/:quadrant_id'}
  @resource 'ships', {path: '/ships'}, () ->
    @route 'show', {path: '/:ship_id'}
  @resource 'bases', {path: '/bases'}, () ->
    @route 'show', {path: '/:base_id'}
  @resource 'players', {path: '/players'}, () ->
    @route 'show', {path: '/:player_id'}


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


TheSkyMap.QuadrantShowRoute = Ember.Route.extend
  model: (params)->
    this.store.find('quadrant', params.quadrant_id)


TheSkyMap.ShipsIndexRoute = Ember.Route.extend
  model: (params) ->
    @store.find('ship')
TheSkyMap.ShipsShowRoute = Ember.Route.extend
  model: (params)->
    ship = @store.reloadRecord(@store.recordForId('ship', params.ship_id))


TheSkyMap.BasesIndexRoute = Ember.Route.extend
  model: (params) ->
    @store.find('base')
TheSkyMap.BasesShowRoute = Ember.Route.extend
  model: (params)->
    ship = @store.reloadRecord(@store.recordForId('base', params.base_id))




