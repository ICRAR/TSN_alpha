# http://emberjs.com/guides/models/using-the-store/

TheSkyMap.UnauthorizedError = () ->
  tmp = Error.prototype.constructor.call(this, "The backend returned a 401: Unauthorized Error, : ")
  tmp.name = "UnauthorizedError"

TheSkyMap.UnauthorizedError.prototype = Ember.create(Error.prototype)


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
    defaultAjaxError = @_super(jqXHR)
    if jqXHR and jqXHR.status is 401
      window.location.replace("/users/sign_in")
      new TheSkyMap.UnauthorizedError()
    else
      defaultAjaxError

