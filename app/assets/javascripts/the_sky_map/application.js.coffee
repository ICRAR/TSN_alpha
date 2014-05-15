#= require jquery
#= require_tree ./vendor
#= require ./init.js.coffee
#= require handlebars
#= require ember
#= require ember-data
#= require_self
#= require ./the_sky_map

# for more details see: http://emberjs.com/guides/application/
window.TheSkyMap = Ember.Application.create(
  LOG_TRANSITIONS: true
)


