# Crucible

Code as infrastructure

## Idea

"Infrastructure as code" is a misnomer.

We should call it "infrastructure as configuration" or "infrastructure as data"
because YAML (Ansible/CloudFormation) and glorified JSON (Terraform) are not code.

Just as functional languages enable us to treat
[code as data](https://blogs.mulesoft.com/dev/news-dev/code-is-data-data-is-code/),
I believe they give us the capability to treat code as infrastructure. Crucible is
going to explore this idea.

## Core concepts

1. Declarative and idempotent
2. Granular control of create/delete/rollback behavior
3. Rollbacks as a first class citizen
4. Testing as a first class citizen
5. Does not track state outside of execution

## Thought dump

```elixir
defmodule My.VPC do
  @moduledoc """
  Some thoughts on what the end goal could look like.
  """
  use Crucible

  alias Crucible.AWS.VPC
  alias Crucible.AWS.Subnet

  @vpc %VPC{
    cidr: "10.0.0.0/16"
    tags: [foo: "bar", abc: "xyz"]
  }

  def init(infra) do
    infra
    |> declare(:my_vpc, @vpc)
    |> declare(:my_subnet_1, subnet("1"))
    |> declare(:my_subnet_2, subnet("2"))
    |> declare(:my_subnet_3, subnet("3"))
  end

  @doc """
  This is a pseudo-code example of pattern matching an edge case.
  Only create `:my_subnet_3` if `APPENV` environment variable is
  equal to "prod."
  """
  def handle_create(%{state: %{my_vpc: vpc}} = _infra, %Subnet{cid: :my_subnet_3} = sn) do
    with "prod" <- System.get_env("APPENV"),
         sn3 <- %{sn | vpc: vpc},
         {:ok, _} = resp <- Subnet.create(sn3) do
      resp
    else
      {:error, _} = err ->
        err
      _ ->
        {:ok, %{}}
    end
  end

  defp subnet(i) do
    %Subnet{
      vpc: :my_vpc,
      cidr: "10.0.#{i}.0/24",
      tags: [foo: "baz"]
    }
  end
end

defmodule My.Vpc do
  @moduledoc """
  Provide a more declarative DSL, too.
  """
  use Crucible.DSL

  vpc(:my_vpc) do
    subnet :my_subnet_1, cidr: "10.0.3.0/24" do
      vm :jenkins do
      end

      vm :foobar do
      end
    end

    subnet :my_subnet_2, cidr: "10.0.4.0/24" do
      on_create fn x -> do_something(x) end
    end
  end
end
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `crucible` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:crucible, "~> 0.0.1"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/crucible](https://hexdocs.pm/crucible).
