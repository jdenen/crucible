defmodule Grandparent do
  use Crucible.Type
  field :id
end

defmodule Parent do
  use Crucible.Type
  field :id
  field :parent, relationship: Grandparent
end

defmodule Child do
  use Crucible.Type
  field :id
  field :parent_one, relationship: Parent
  field :parent_two, relationship: Parent
end
