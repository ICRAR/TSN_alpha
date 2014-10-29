TheSkyMap.ApplicationController = Ember.Controller.extend
  needs: ['currentPlayer']
  navLinks: ( ()->
    unread_msg_count = @get('controllers.currentPlayer.content.unread_msg_count')
    if unread_msg_count > 0
      msg_title = "Messages (#{unread_msg_count})"
    else
      msg_title = "Messages"
    [
      Ember.Object.create({linkTo: 'home', title: 'Home'})
      #Ember.Object.create({linkTo: 'name', title: 'Name'})
      #Ember.Object.create({linkTo: 'quadrants', title: 'Galaxy Map'})
      Ember.Object.create({linkTo: 'ships', title: 'All Ships'})
      Ember.Object.create({linkTo: 'bases', title: 'All Bases'})
      Ember.Object.create({linkTo: 'players', title: 'All Players'})
      Ember.Object.create({linkTo: 'actions', title: 'All Actions'})
      Ember.Object.create({linkTo: 'messages', title: msg_title})
    ]
  ).property('controllers.currentPlayer.content.unread_msg_count')