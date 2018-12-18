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
    function_name = Module.get_attribute(env.module, :name)
    relationships = Module.get_attribute(env.module, :relationships) || []

    quote do
      if not is_nil(unquote(function_name)) do
        def name() do
          unquote(function_name)
        end
      end

      def relationships() do
        unquote(relationships)
      end
    end
  end
end
