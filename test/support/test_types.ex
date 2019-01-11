defmodule Grandparent do
  use Crucible.Type
  field :id
  field :name
  field :age
end

defmodule Parent do
  use Crucible.Type
  field :id
  field :name
  field :parent, relationship: Grandparent
end

defmodule Child do
  use Crucible.Type
  field :id
  field :name
  field :parent_one, relationship: Parent
  field :parent_two, relationship: Parent
end
