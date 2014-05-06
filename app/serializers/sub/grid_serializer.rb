class Sub::GridSerializer < ActiveModel::Serializer
  attributes :id, :name, :x, :y, :z, :edge
end