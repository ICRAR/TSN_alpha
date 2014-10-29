TheSkyMap.ActionableShowView = TheSkyMap.FullMapPlusSideView.extend
  load_actions: (() ->
    @.get('controller').send('update_actions')
  ).on('didInsertElement')
