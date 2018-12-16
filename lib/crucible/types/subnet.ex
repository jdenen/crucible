defmodule Crucible.Types.Subnet do
  @enforce_keys [:id]
  defstruct id: nil,
            cidr: nil,
            vpc: nil,
            tags: []
end
