# For more information see: http://emberjs.com/guides/routing/

TheSkyMap.Router.map ()->
  # @resource('posts')
  @route 'home', path: '/'
  @route 'name'
  @resource 'grid', {path: '/grid'}, () ->
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
  model: ->
    this.store.find('shout_box', params.shout_id)


TheSkyMap.GridIndexRoute = Ember.Route.extend
  model: ->
    this.store.find('grid')

