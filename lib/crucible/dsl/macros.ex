defmodule Crucible.DSL.Macros do
  Application.get_env(:crucible, :types)
  |> Enum.map(fn type ->
    Code.ensure_compiled(type)

    name = type.name()
    relationships = type.relationships()

    defmacro unquote(name)(id, do: body) do
      Crucible.DSL.write_macro(__CALLER__, unquote(type), id, body, unquote(relationships))
    end
  end)
end
