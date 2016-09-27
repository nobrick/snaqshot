defmodule Snaqshot do
  use Application

  @slack_token Application.get_env(:slack, :api_token)

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(SlackMessaging, [@slack_token]),
      supervisor(Snaqshot.BackupWorker.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: Snaqshot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
