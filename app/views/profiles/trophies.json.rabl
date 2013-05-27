object @profile
attributes :id, :name
child :trophies do
  extends "profiles/trophies_list"
end