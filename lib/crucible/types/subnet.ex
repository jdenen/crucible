defmodule Crucible.Types.Subnet do
  @enforce_keys [:id]
  defstruct id: nil,
            cidr: nil,
            vpc: nil,
            tags: []

  def name(), do: :subnet

  def relationships() do
    [vpc: Crucible.Types.Vpc]
  end
end
