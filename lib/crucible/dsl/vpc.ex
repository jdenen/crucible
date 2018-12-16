defmodule Crucible.DSL.Vpc do
  defmacro vpc(id, do: body) do
    function_name = "vpc_#{id}" |> String.to_atom()

    fields = get_fields(Crucible.Types.Vpc, body)
    stripped_body = remove_field_assignments(fields, body)

    quote do
      Module.put_attribute(__MODULE__, :crucible_dsl_functions, unquote(function_name))

      def unquote(function_name)() do
        Process.put(:crucible_dsl_vpc, unquote(id))
        unquote(stripped_body)

        struct_values =
          Enum.reduce(unquote(fields), %{}, fn {field, value}, acc ->
            Map.put(acc, field, value)
          end)

        struct(Crucible.Types.Vpc, Map.put(struct_values, :id, unquote(id)))
        |> Crucible.DSL.Store.put()

        Process.delete(:crucible_dsl_vpc)
        :ok
      end
    end
  end

  defp remove_field_assignments(fields, body) do
    Macro.prewalk(body, fn exp ->
      with {:=, _, [{field, _, nil}, value]} <- exp,
           true <- Keyword.has_key?(fields, field),
           true <- Keyword.get(fields, field) == value do
        nil
      else
        _ -> exp
      end
    end)
  end

  defp get_fields(struct_module, {:__block__, _, body}) do
    get_fields(struct_module, body)
  end
  defp get_fields(struct_module, body) do
    struct_fields = struct_fields(struct_module)

    Macro.prewalk(body, &remove_macro_blocks/1)
    |> Macro.prewalk([], fn exp, acc ->
      with {:=, _, [{field, _, nil}, value]} <- exp,
      true <- field in struct_fields,
      false <- Keyword.has_key?(acc, field) do
        {nil, [{field, value} | acc]}
      else
        _ -> {exp, acc}
      end
    end)
    |> elem(1)
  end

  defp remove_macro_blocks({:__block__, _, _}), do: nil
  defp remove_macro_blocks(x), do: x

  defp struct_fields(module) do
    module.__struct__()
    |> Map.keys()
    |> Enum.filter(&(&1 != :__struct__))
  end
end
