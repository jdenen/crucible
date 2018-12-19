defmodule Crucible.DependencyTreeTest do
  use ExUnit.Case
  alias Graph.Edge
  alias Crucible.DependencyTree

  describe "chunk" do
    test "returns chunk with no dependencies first" do
      g =
        Graph.new
        |> Graph.add_edges([Edge.new(:a, :b), Edge.new(:b, :c), Edge.new(:b, :d)])

      [no_deps | _] = DependencyTree.chunk(g)
      assert no_deps == [:c, :d]
    end

    test "subsequent chunks have had their dependencies previously chunked" do
      g =
        Graph.new
        |> Graph.add_edges([Edge.new(:a, :b), Edge.new(:b, :c), Edge.new(:b, :d)])

      [_ | subsequent] = DependencyTree.chunk(g)
      assert subsequent == [[:b], [:a]]
    end

    test "vertices are chunked together regardless of their depth in the tree" do
      g =
        Graph.new
        |> Graph.add_edge(:a, :b)
        |> Graph.add_edge(:a, :c)
        |> Graph.add_edge(:a, :d)
        |> Graph.add_edge(:c, :e)
        |> Graph.add_edge(:e, :f)
        |> Graph.add_edge(:f, :g)
        |> Graph.add_edge(:c, :h)
        |> Graph.add_edge(:d, :i)

      assert DependencyTree.chunk(g) == [[:b, :g, :h, :i], [:d, :f], [:e], [:c], [:a]]
    end

    test "vertex without dependents returns in first chunk" do
      g =
        Graph.new
        |> Graph.add_edge(:a, :b)
        |> Graph.add_vertex(:c)

      assert DependencyTree.chunk(g) == [[:b, :c], [:a]]
    end
  end
end
