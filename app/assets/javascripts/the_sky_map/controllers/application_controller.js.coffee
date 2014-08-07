TheSkyMap.ApplicationController = Ember.Controller.extend
  needs: ['currentPlayer']
  navLinks: [
    Ember.Object.create({linkTo: 'home', title: 'Home'})
    #Ember.Object.create({linkTo: 'name', title: 'Name'})
    #Ember.Object.create({linkTo: 'quadrants', title: 'Galaxy Map'})
    Ember.Object.create({linkTo: 'ships', title: 'All Ships'})
    Ember.Object.create({linkTo: 'bases', title: 'All Bases'})
    Ember.Object.create({linkTo: 'players', title: 'All Players'})
    Ember.Object.create({linkTo: 'actions', title: 'All Actions'})
  ]