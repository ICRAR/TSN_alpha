# http://emberjs.com/guides/models/using-the-store/

TheSkyMap.UnauthorizedError = () ->
  tmp = Error.prototype.constructor.call(this, "The backend returned a 401: Unauthorized Error, : ")
  tmp.name = "UnauthorizedError"
  tmp
TheSkyMap.UnfoundError = () ->
  tmp = Error.prototype.constructor.call(this, "The backend returned a 404: File Not Found Error, : ")
  tmp.name = "UnfoundError"
  tmp

TheSkyMap.UnauthorizedError.prototype = Ember.create(Error.prototype)
TheSkyMap.UnfoundError.prototype = Ember.create(Error.prototype)


TheSkyMap.Store = DS.Store.extend
  # Override the default adapter with the `DS.ActiveModelAdapter` which
  # is built to work nicely with the ActiveModel::Serializers gem.
  #revision: 12,
  adapter: '-active-model'
DS.RESTAdapter.reopen
  namespace: 'the_sky_map'

DS.ActiveModelAdapter.reopen
  init: ->
    @_super()
    token = $("meta[name=\"csrf-token\"]").attr("content")
    @headers = "X-CSRF-Token": token
  ajaxError: (jqXHR) ->
    if jqXHR
      if jqXHR.status is 401
        window.location.replace("/users/sign_in")
        new TheSkyMap.UnauthorizedError()
      else if jqXHR.status is 404
        new TheSkyMap.UnfoundError()
    else
      @_super(jqXHR)

TheSkyMap.RawTransform = DS.Transform.extend(
  deserialize: (serialized) ->
    serialized

  serialize: (deserialized) ->
    deserialized
)

