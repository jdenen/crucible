defmodule Crucible.DSL do
  defmacro __using__(_opts) do
    quote do
      import Crucible.DSL.Vpc
      import Crucible.DSL.Subnet
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
end
