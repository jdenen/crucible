defmodule Crucible.Types.Vpc do
  use Crucible.Type

  @name :vpc

  @enforce_keys [:id]
  defstruct id: nil,
            tags: []
end
