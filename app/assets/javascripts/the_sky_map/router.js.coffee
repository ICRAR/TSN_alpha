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
  @route 'actions', path: '/actions'
  @resource 'messages', {path: '/messages'}, () -> {}



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


TheSkyMap.LoadingRoute = Ember.Route.extend
  viewName: 'fullWidth'

TheSkyMap.HomeRoute = Ember.Route.extend
  viewName: 'full_map_plus_side'

TheSkyMap.QuadrantsIndexRoute = Ember.Route.extend
  viewName: 'full_map_plus_side'

TheSkyMap.QuadrantsShowRoute = Ember.Route.extend TheSkyMap.SelectableRoute,
  viewName: 'full_map_plus_side'
  model: (params)->
    quadrant = @store.reloadRecord(@store.recordForId('quadrant', params.quadrant_id))

TheSkyMap.ShipsShowLoadingRoute = Ember.Route.extend
  viewName: 'full_map_plus_side'

TheSkyMap.ShipsIndexRoute = Ember.Route.extend TheSkyMap.PaginateableRouter,
  viewName: 'plus_mini_map'
  model: (params) ->
    @store.find('ship', params)

TheSkyMap.ShipsShowRoute = Ember.Route.extend TheSkyMap.SelectableRoute,
  viewName: 'actionable_show'
  model: (params)->
    ship = @store.reloadRecord(@store.recordForId('ship', params.ship_id))

TheSkyMap.BasesIndexRoute = Ember.Route.extend TheSkyMap.PaginateableRouter,
  viewName: 'plus_mini_map'
  model: (params) ->
    @store.find('base', params)
TheSkyMap.BasesShowRoute = Ember.Route.extend TheSkyMap.SelectableRoute,
  viewName: 'actionable_show'
  model: (params)->
    base = @store.reloadRecord(@store.recordForId('base', params.base_id))


TheSkyMap.PlayersIndexRoute = Ember.Route.extend TheSkyMap.PaginateableRouter,
  viewName: 'plus_mini_map'
  model: (params) ->
    @store.find('player', params)
TheSkyMap.PlayersShowRoute = Ember.Route.extend
  viewName: 'full_map_plus_side'
  model: (params)->
    player = @store.reloadRecord(@store.recordForId('player', params.player_id))

TheSkyMap.ActionsRoute = Ember.Route.extend TheSkyMap.PaginateableRouter,
  viewName: 'plus_mini_map'
  model: (params) ->
    @store.find('action', params)

TheSkyMap.MessagesIndexRoute = Ember.Route.extend TheSkyMap.PaginateableRouter,
  viewName: 'plus_mini_map'
  model: (params) ->
    @store.find('message', params)

