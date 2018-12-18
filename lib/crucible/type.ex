defmodule Crucible.Type do
  @callback name() :: atom
  @callback relationships :: keyword

  defmacro __using__(_opts) do
    quote do
      @behaviour Crucible.Type
      @before_compile Crucible.Type
    end
  end

  defmacro __before_compile__(env) do
    function_name = Module.get_attribute(env.module, :name) || generate_function_name(env.module)
    relationships = Module.get_attribute(env.module, :relationships) || []

    quote do
      def name() do
        unquote(function_name)
      end

      def relationships() do
        unquote(relationships)
      end
    end
  end

  defp generate_function_name(module) do
    module |> Module.split() |> List.last() |> String.downcase() |> String.to_atom()
  end
end
