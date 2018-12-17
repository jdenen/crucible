defmodule Crucible.DSL.Store do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def put(term) do
    GenServer.cast(__MODULE__, {:put, term})
  end

  def get_all() do
    GenServer.call(__MODULE__, :get_all)
  end

  def clear() do
    GenServer.cast(__MODULE__, :clear)
  end

  def handle_cast({:put, term}, state) do
    {:noreply, [term | state]}
  end

  def handle_cast(:clear, _state) do
    {:noreply, []}
  end

  def handle_call(:get_all, _from, state) do
    {:reply, state, state}
  end
end
