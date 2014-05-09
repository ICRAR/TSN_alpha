TheSkyMap.CurrentProfile = DS.Model.extend(
  name: DS.attr("string")
  email: DS.attr("string")
  user_id: DS.attr("number")
  user_signed_in: DS.attr("boolean")
  base_x: DS.attr("number")
  base_y: DS.attr("number")
  base_z: DS.attr("number")
)

