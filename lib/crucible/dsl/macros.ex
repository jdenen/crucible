defmodule Crucible.DSL.Macros do
  Application.get_env(:crucible, :types)
  |> Enum.map(fn type ->
    case Code.ensure_compiled(type) do
      {:error, reason} ->
        IO.puts("Unable to compile Macros, #{type} -> #{inspect(reason)}")

      _ ->
        name = type.name()
        relationships = type.relationships()

        defmacro unquote(name)(id, do: body) do
          Crucible.DSL.write_macro(__CALLER__, unquote(type), id, body, unquote(relationships))
        end
    end
  end)
end
