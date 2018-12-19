defmodule Crucible.DSL do
  defmacro __using__(_opts) do
    quote do
      @compile :nowarn_unused_vars
      import Crucible.DSL.Macros
      @before_compile Crucible.DSL
      Module.register_attribute(__MODULE__, :crucible_dsl_functions, accumulate: true)
    end
  end

  defmacro __before_compile__(env) do
    functions = Module.get_attribute(env.module, :crucible_dsl_functions)

    quote do
      def process_infrastructure() do
        Enum.each(unquote(functions), fn func -> apply(__MODULE__, func, []) end)
        :ok
      end
    end
  end

  def write_macro(caller, type, id, body, opts \\ []) do
    function_name = function_name(type, id)

    fields = get_fields(type, body)
    stripped_body = remove_field_assignments(fields, body)

    case caller.function do
      nil -> write_function(function_name, type, id, fields, stripped_body)
      _ -> write_body(type, id, fields, body, opts)
    end
  end

  defp write_body(type, id, fields, body, opts) do
    fields = Keyword.put(fields, :id, id)

    quote generated: true do
      Process.put(unquote(type), unquote(id))
      unquote(body)

      values = Enum.into(unquote(fields), %{})

      values = Enum.reduce(unquote(opts), values, fn {k, v}, acc -> Map.put(acc, k, Process.get(v)) end)

      struct(unquote(type), values)
      |> Crucible.DSL.Store.put()

      Process.delete(unquote(type))
    end
  end

  defp write_function(function_name, type, id, fields, body) do
    quote generated: true do
      Module.put_attribute(__MODULE__, :crucible_dsl_functions, unquote(function_name))

      def unquote(function_name)() do
        unquote(write_body(type, id, fields, body, []))
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
  defp remove_macro_blocks({:do, _}), do: nil
  defp remove_macro_blocks(x), do: x

  defp struct_fields(module) do
    module.__struct__()
    |> Map.keys()
    |> Enum.filter(&(&1 != :__struct__))
  end

  defp function_name(type, id) do
    prefix =
      type
      |> to_string()
      |> String.downcase()
      |> String.replace(".", "_")

    "#{prefix}_#{id}" |> String.to_atom()
  end
end
