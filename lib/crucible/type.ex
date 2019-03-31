defmodule Crucible.Type do
  @callback name() :: atom
  @callback relationships :: keyword

  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :crucible_fields, accumulate: true)
      @behaviour Crucible.Type
      @before_compile Crucible.Type
      import Crucible.Type, only: [field: 1, field: 2]
    end
  end

  defmacro field(name, opts \\ []) do
    quote bind_quoted: [name: name, opts: opts] do
      Module.put_attribute(__MODULE__, :crucible_fields, {name, opts})
    end
  end

  defmacro __before_compile__(env) do
    function_name = Module.get_attribute(env.module, :name) || generate_function_name(env.module)
    fields = Module.get_attribute(env.module, :crucible_fields)

    struct_fields = Enum.map(fields, fn {name, opts} -> {name, Keyword.get(opts, :default, nil)} end)

    enforced_fields =
      fields
      |> Enum.filter(fn {_name, opts} -> Keyword.get(opts, :required, false) == true end)
      |> Enum.map(&elem(&1, 0))

    relationships =
      fields
      |> Enum.map(fn {name, opts} -> {name, Keyword.get(opts, :relationship, nil)} end)
      |> Enum.filter(fn {_name, relationship} -> relationship != nil end)

    quote do
      @enforce_keys unquote(enforced_fields)
      defstruct(unquote(struct_fields))

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
