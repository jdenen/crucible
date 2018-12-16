defmodule Crucible.DSL.VpcTest do
  use ExUnit.Case

  setup do
    Crucible.DSL.Store.clear()
    :ok
  end

  test "simple vpc test" do
    Crucible.DSL.VpcTest.Simple.process_infrastructure()

    vpc = find(Crucible.Types.Vpc, :vpc_1)

    assert vpc.tags == ["vpc"]
  end

  test "subnet embedded in vpc" do
    Crucible.DSL.VpcTest.Simple.process_infrastructure()

    subnet = find(Crucible.Types.Subnet, :subnet_1)

    assert subnet.cidr == "10.0.24.0/16"
    assert subnet.vpc == :vpc_1
    assert subnet.tags == ["subnet"]
  end

  defp find(type, id) do
    Crucible.DSL.Store.get_all()
    |> Enum.find(fn struct -> Map.get(struct, :__struct__) == type && struct.id == id end)
  end
end

defmodule Crucible.DSL.VpcTest.Simple do
  use Crucible.DSL

  vpc :vpc_1 do
    tags = determine_tags()

    subnet :subnet_1 do
      cidr = "10.0.24.0/16"
      tags = ["subnet"]
    end
  end

  defp determine_tags() do
    ["vpc"]
  end
end
