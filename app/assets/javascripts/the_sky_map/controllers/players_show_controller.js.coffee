TheSkyMap.PlayersShowController = TheSkyMap.ActionableController.extend
  profile_link: (() ->
    "/profiles/#{@get('profile_id')}"
  ).property('profile_id')