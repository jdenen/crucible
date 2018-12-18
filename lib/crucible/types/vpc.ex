defmodule Crucible.Types.Vpc do
  use Crucible.Type

  @enforce_keys [:id]
  defstruct id: nil,
            tags: []
end
