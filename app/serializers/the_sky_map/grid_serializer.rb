class TheSkyMap::GridSerializer < ActiveModel::Serializer
  attributes :id, :name, :x, :y, :z, :edge
end