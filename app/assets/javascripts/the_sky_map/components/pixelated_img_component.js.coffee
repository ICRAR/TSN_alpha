TheSkyMap.PixelatedImgComponent = Ember.Component.extend
  src: ''
  width: 80
  height: 80
  value: 0.5
  run_pixelate: (() ->
    $(@get('element')).children('img').first().load(() ->
      $(@).pixelate()
    )
  ).on('didInsertElement')