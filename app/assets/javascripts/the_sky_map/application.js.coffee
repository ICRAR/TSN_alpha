#= require jquery
#= require ./init.js.coffee
#= require ./faye.js.coffee.erb
#= require handlebars
#= require ember
#= require ember-data
#= require_tree ./vendor
#= require messenger
#= require messenger-theme-future
#= require_self
#= require ./the_sky_map

# for more details see: http://emberjs.com/guides/application/
window.TheSkyMap = Ember.Application.create(
  LOG_TRANSITIONS: true
)


