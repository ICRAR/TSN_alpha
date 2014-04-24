# For more information see: http://emberjs.com/guides/routing/

TheSkyMap.Router.map ()->
  # @resource('posts')
  @route 'shout_boxes', path: '/'
TheSkyMap.ShoutBoxesRoute = Ember.Route.extend
  model: ->
    this.store.find('shout_box')
