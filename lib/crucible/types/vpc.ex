defmodule Crucible.Types.Vpc do
  use Crucible.Type

  field :id, required: true
  field :tags, default: []

end
