Code.compile_file("lib/crucible/dsl/macros.ex")
ExUnit.start(exclude: [:skip])

defmodule Helper do
  defmacro with_module(do: do_block) do
    body = Macro.to_string(do_block)

    quote do
      Code.eval_string(unquote(body))
    end
  end

  def unload_module(module) do
    :code.purge(module)
    :code.delete(module)
  end
end
