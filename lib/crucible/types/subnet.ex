defmodule Crucible.Types.Subnet do
  use Crucible.Type

  field :id, required: true
  field :cidr
  field :vpc, relationship: Crucible.Types.Vpc
  field :tags, default: []
end
