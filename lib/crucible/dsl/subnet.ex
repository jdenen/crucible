defmodule Crucible.DSL.Subnet do
  defmacro subnet(id, do: body) do
    function_name = "subnet_#{id}" |> String.to_atom()

    struct_fields = struct_fields(Crucible.Types.Subnet)

    {stripped_body, fields} =
      Macro.prewalk(body, [], fn exp, acc ->
        with {:=, _, [{field, _, nil}, value]} <- exp,
             true <- field in struct_fields do
          {nil, [{field, value} | acc]}
        else
          _ -> {exp, acc}
        end
      end)

    quote do
      unquote(stripped_body)

      struct_values =
        Enum.reduce(unquote(fields), %{}, fn {field, value}, acc ->
          Map.put(acc, field, value)
        end)

      struct_values = Map.put(struct_values, :vpc, Process.get(:crucible_dsl_vpc))

      struct(Crucible.Types.Subnet, Map.put(struct_values, :id, unquote(id)))
      |> Crucible.DSL.Store.put()
    end
  end

  defp struct_fields(module) do
    module.__struct__()
    |> Map.keys()
    |> Enum.filter(&(&1 != :__struct__))
  end
end
