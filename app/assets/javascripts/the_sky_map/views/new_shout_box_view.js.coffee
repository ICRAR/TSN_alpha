TheSkyMap.NewShoutBoxView = Ember.View.extend
  templateName: 'new_shout_box'
  tagName: 'form'

  submit: ->
    @get('controller').send('addShoutBox', @get('newShoutBoxMsg'))
    @set('newShoutBoxMsg', "")
    false