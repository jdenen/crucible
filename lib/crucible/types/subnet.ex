defmodule Crucible.Types.Subnet do
  use Crucible.Type

  @relationships [vpc: Crucible.Types.Vpc]

  @enforce_keys [:id]
  defstruct id: nil,
            cidr: nil,
            vpc: nil,
            tags: []
end
