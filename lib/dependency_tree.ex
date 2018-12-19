defmodule Crucible.DependencyTree do
  def chunk(graph) do
    graph
    |> chunk_dependencies
    |> Enum.reverse
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
