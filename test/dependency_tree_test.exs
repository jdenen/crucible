defmodule Crucible.DependencyTreeTest do
  use ExUnit.Case
  alias Graph.Edge
  alias Crucible.DependencyTree

  describe "graph"  do
    test "all elements are added to the tree" do
      vs = [
        %Parent{id: :p2, parent: :g},
        %Grandparent{id: :g},
        %Parent{id: :p1},
        %Child{id: :c, parent_one: :p1}
      ]

      tree = DependencyTree.graph(vs)
      assert Enum.all?(vs, &Graph.has_vertex?(tree, &1))
    end

    test "edges are established between parent and child" do
      parent = %Parent{id: :p1}
      child = %Child{id: :c, parent_one: :p1}

      expected = [Edge.new(child, parent)]
      actual = tree_edges([parent, child])

      assert has_expected_edges(expected, actual)
      assert has_no_unexpected_edges(expected, actual)
    end

    test "elements can have multiple dependents" do
      parent = %Parent{id: :parent}
      child1 = %Child{id: :c1, parent_one: :parent}
      child2 = %Child{id: :c2, parent_one: :parent}

      expected = [Edge.new(child1, parent), Edge.new(child2, parent)]
      actual = tree_edges([child1, parent, child2])

      assert has_expected_edges(expected, actual)
      assert has_no_unexpected_edges(expected, actual)
    end

    test "elements can have multiple dependencies" do
      parent1 = %Parent{id: :p1}
      parent2 = %Parent{id: :p2}
      child = %Child{id: :c, parent_one: :p1, parent_two: :p2}

      expected = [Edge.new(child, parent1), Edge.new(child, parent2)]
      actual = tree_edges([parent1, parent2, child])

      assert has_expected_edges(expected, actual)
      assert has_no_unexpected_edges(expected, actual)
    end
  end

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

  defp tree_edges(list) do
    list
    |> DependencyTree.graph
    |> Graph.edges
  end

  defp has_expected_edges(expected, actual) do
    Enum.all?(expected, &Enum.member?(actual, &1))
  end

  defp has_no_unexpected_edges(expected, actual) do
    not Enum.any?(actual, fn e -> not Enum.member?(expected, e) end)
  end
end
