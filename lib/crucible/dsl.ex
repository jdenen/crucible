defmodule Crucible.DSL do
  defmacro __using__(_opts) do
    quote do
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
        Crucible.DSL.Store.get_all()
      end
    end
  end

  def write_macro(caller, type, id, body, relationships \\ []) do
    case caller.function do
      nil -> write_function(type, id, body, relationships)
      _ -> write_body(type, id, body, relationships)
    end
  end

  defp write_function(type, id, body, relationships) do
    function_name = function_name(type, id)

    quote do
      Module.put_attribute(__MODULE__, :crucible_dsl_functions, unquote(function_name))

      def unquote(function_name)() do
        Process.put(unquote(type), unquote(id))
        unquote(write_body(type, id, body, relationships))
        Process.delete(unquote(type))
      end
    end
  end

  defp write_body(type, id, body, relationships) do
    {assignments, blocks} = separate_assignments_and_blocks(body)

    fields =
      get_fields(type, body)
      |> Enum.map(fn field -> {field, Macro.var(field, nil)} end)
      |> Keyword.put(:id, id)

    quote do
      unquote_splicing(Enum.reverse(blocks))
      unquote(assignments)

      values = Enum.reduce(unquote(relationships), unquote(fields), fn {k, v}, acc -> Keyword.put(acc, k, Process.get(v)) end)

      struct(unquote(type), values)
      |> Crucible.DSL.Store.put()
    end
  end

  defp separate_assignments_and_blocks(body) do
    Macro.prewalk(body, [], fn exp, acc ->
      case is_macro?(exp, get_macros()) do
        true -> {nil, [exp | acc]}
        false -> {exp, acc}
      end
    end)
  end

  defp is_macro?({function, _, _}, macros) do
    function in macros
  end

  defp is_macro?(_, _), do: false

  defp get_macros() do
    Crucible.DSL.Macros.__info__(:macros)
    |> Enum.map(fn {name, _arity} -> name end)
  end

  defp get_fields(struct_module, body) do
    struct_fields = struct_fields(struct_module)

    {_, fields} =
      Macro.prewalk(body, &remove_macro_blocks(&1, get_macros()))
      |> Macro.prewalk([], fn exp, acc ->
        with {:=, _, [{field, _, nil}, _value]} <- exp,
             true <- field in struct_fields do
          {exp, [field | acc]}
        else
          _ -> {exp, acc}
        end
      end)

    fields
  end

  defp remove_macro_blocks({function, _, _} = ast, macros) do
    case function in macros do
      true -> nil
      false -> ast
    end
  end

  defp remove_macro_blocks(x, _), do: x

  defp struct_fields(module) do
    module.__struct__()
    |> Map.keys()
    |> Enum.filter(fn x -> x != :__struct__ end)
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
