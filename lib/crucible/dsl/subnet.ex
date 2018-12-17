defmodule Crucible.DSL.Subnet do
  defmacro subnet(id, do: body) do
    Crucible.DSL.write_macro(__CALLER__, Crucible.Types.Subnet, id, body, vpc: Crucible.Types.Vpc)
  end
end
