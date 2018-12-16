defmodule Crucible.Types.Vpc do
  @enforce_keys [:id]
  defstruct id: nil,
            tags: []
end
