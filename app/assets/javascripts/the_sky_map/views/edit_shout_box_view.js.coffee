TheSkyMap.EditShoutBoxView = Ember.TextField.extend
  didInsertElement: () ->
    this.$().focus()

Ember.Handlebars.helper('edit-shout_box', TheSkyMap.EditShoutBoxView)