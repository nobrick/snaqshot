defmodule Snaqshot.BackupWorker.Supervisor do
  use Supervisor
  alias Snaqshot.BackupWorker

  def start_link(args \\ [{%{}, []}, [name: BackupWorker]]) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    children = [
      worker(BackupWorker, args, restart: :transient)
    ]

    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end
end
