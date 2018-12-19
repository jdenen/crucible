defmodule Crucible.DependencyTree do
  alias Graph.Edge

  def graph(resources) do
    independents =
      resources
      |> Enum.filter(fn struct -> struct.__struct__.relationships == [] end)

    resources
    |> to_edges
    |> Enum.reduce(Graph.new(type: :directed), &Graph.add_edge(&2, &1))
    |> Graph.add_vertices(independents)
  end

  def chunk(graph) do
    graph
    |> chunk_dependencies
    |> Enum.reverse
  end

  defp to_edges(resources) do
    Enum.flat_map(resources, fn struct ->
      struct.__struct__.relationships
      |> Enum.flat_map(&to_dependency(&1, struct, resources))
      |> Enum.map(&Edge.new(struct, &1))
    end)
  end

  defp to_dependency({field, type} = _rel, child, resources) do
    key = Map.get(child, field)

    resources
    |> Enum.filter(&find_dependency(&1, type, key))
  end

  defp find_dependency(%{id: id} = struct, match_type, match_key) do
    struct.__struct__ == match_type and id == match_key
  end

  defp chunk_dependencies(graph, acc \\ [])
  defp chunk_dependencies(%{vertices: vs}, acc) when map_size(vs) == 0, do: acc
  defp chunk_dependencies(graph, acc) do
    chunk =
      graph
      |> Graph.vertices
      |> Enum.filter(fn v -> Graph.out_neighbors(graph, v) == [] end)

    chunk
    |> Enum.reduce(graph, &Graph.delete_vertex(&2, &1))
    |> chunk_dependencies([chunk | acc])
  end
end
