TheSkyMap.isLoadedable = Ember.Mixin.create
  isLoaded: false
  isLoading: (() ->
    !@get('isLoaded')
  ).property('isLoaded')