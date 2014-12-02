# For more information see: http://emberjs.com/guides/routing/

TheSkyMap.Router.map ()->
  # @resource('posts')
  @route 'home', path: '/'
  @route 'name'
  @route 'fmps', {path: '/fmps'}, () ->
    @resource 'quadrants', {path: '/quadrants'}, () ->
    @resource 'quadrant', {path: '/quadrant'}, () ->
      @route 'show', {path: '/:quadrant_id'}
    @resource 'ship', {path: '/ship'}, () ->
      @route 'show', {path: '/:ship_id'}
    @resource 'base', {path: '/base'}, () ->
      @route 'show', {path: '/:base_id'}
    @resource 'player', {path: '/player'}, () ->
      @route 'show', {path: '/:player_id'}
  @route 'pmm', {path: '/pmm'}, () ->
    @resource 'ships', {path: '/ships'}, () -> {}
    @resource 'bases', {path: '/bases'}, () -> {}
    @resource 'players', {path: '/players'}, () -> {}
    @resource 'actions', {path: '/actions'}, () -> {}
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


TheSkyMap.HomeRoute = Ember.Route.extend
  redirect: () ->
    @transitionTo('quadrants')


TheSkyMap.FmpsRoute = Ember.Route.extend
  viewName: 'full_map_plus_side'
  templateName: 'blank'

TheSkyMap.PmmRoute = Ember.Route.extend
  viewName: 'plus_mini_map'
  templateName: 'blank'

TheSkyMap.QuadrantShowRoute = Ember.Route.extend TheSkyMap.SelectableRoute,
  model: (params)->
    quadrant = @store.reloadRecord(@store.recordForId('quadrant', params.quadrant_id))


TheSkyMap.ShipsIndexRoute = Ember.Route.extend TheSkyMap.PaginateableRouter,
  model: (params) ->
    @store.find('ship', params)

TheSkyMap.ShipShowRoute = Ember.Route.extend TheSkyMap.SelectableRoute,
  viewName: 'actionable_show'
  model: (params)->
    ship = @store.reloadRecord(@store.recordForId('ship', params.ship_id))

TheSkyMap.BasesIndexRoute = Ember.Route.extend TheSkyMap.PaginateableRouter,
  model: (params) ->
    @store.find('base', params)
TheSkyMap.BaseShowRoute = Ember.Route.extend TheSkyMap.SelectableRoute,
  viewName: 'actionable_show'
  model: (params)->
    base = @store.reloadRecord(@store.recordForId('base', params.base_id))


TheSkyMap.PlayersIndexRoute = Ember.Route.extend TheSkyMap.PaginateableRouter,
  model: (params) ->
    @store.find('player', params)
TheSkyMap.PlayerShowRoute = Ember.Route.extend
  model: (params)->
    player = @store.reloadRecord(@store.recordForId('player', params.player_id))

TheSkyMap.ActionsIndexRoute = Ember.Route.extend TheSkyMap.PaginateableRouter,
  model: (params) ->
    @store.find('action', params)

TheSkyMap.MessagesIndexRoute = Ember.Route.extend TheSkyMap.PaginateableRouter,
  model: (params) ->
    @store.find('message', params)

