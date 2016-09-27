defmodule SlackMessaging do
  use Slack
  alias Snaqshot.Client

  @post_opts %{username: "kano-snapshots", icon_emoji: ":tiger:"}
  @default_channel "#snapshots"

  ## Web API

  def post(msg, channel \\ nil, opts \\ %{}) do
    Slack.Web.Chat.post_message(channel || @default_channel, msg,
                                Map.merge(@post_opts, opts))
  end

  ## Slack RTM Callbacks

  def handle_connect(slack) do
    IO.puts "#{__MODULE__} connected as #{slack.me.name}"
  end

  def handle_message(%{type: "message", text: text} = msg, slack) do
    case text |> String.trim |> String.downcase do
      t when t in ~w(backup snapshot) -> perform_backup(msg, slack)
      t when t in ~w(list describe)   -> describe_snapshots(msg, slack)
      _                               -> send_help_message(msg, slack)
    end
  end

  def handle_message(_, _), do: :ok

  def handle_info({:message, text, channel}, slack) do
    send_message(text, channel, slack)
  end

  def handle_info(_, _), do: :ok

  ## Helpers

  defp send_help_message(%{user: me} = _msg, %{me: %{id: me}} = _slack) do
    :ok
  end

  defp send_help_message(%{channel: channel} = _msg, slack) do
    send_message("Didn't got what you say. Reply *backup* to make " <>
                 "a snapshot", channel, slack)
  end

  defp describe_snapshots(%{channel: channel} = _msg, slack) do
    Client.describe_snapshots
    |> inspect
    |> send_message(channel, slack)
  end

  defp perform_backup(%{channel: channel} = _msg, slack) do
    Snaqshot.BackupWorker.perform
    send_message("Performing the backup...", channel, slack)
  end
end
