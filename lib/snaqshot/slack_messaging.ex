defmodule SlackMessaging do
  use Slack

  @post_opts %{username: "kano-snapshots", icon_emoji: ":tiger:"}
  @default_channel "#snapshots"

  def post(msg, channel \\ nil, opts \\ %{}) do
    Slack.Web.Chat.post_message(channel || @default_channel, msg,
                                Map.merge(@post_opts, opts))
  end
end
