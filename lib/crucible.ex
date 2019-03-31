defmodule Crucible do
  use Application

  def start(_type, _args) do
    children = []

    opts = [strategy: :one_for_one, name: Crucible.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
