TheSkyMap.CurrentPlayer = DS.Model.extend(
  name: DS.attr("string")
  email: DS.attr("string")
  profile_id: DS.attr("number")
  user_signed_in: DS.attr("boolean")
  home_x: DS.attr("number")
  home_y: DS.attr("number")
  home_z: DS.attr("number")
  currency_available: DS.attr("number")
  currency_available_special: DS.attr("number")
)

