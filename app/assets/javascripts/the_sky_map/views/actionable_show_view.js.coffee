TheSkyMap.ActionableShowView = Ember.View.extend
  load_actions: (() ->
    @.get('controller').send('update_actions')
  ).on('didInsertElement')
