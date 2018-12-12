defmodule CrucibleTest do
  use ExUnit.Case
  doctest Crucible

  test "greets the world" do
    assert Crucible.hello() == :world
  end
end
