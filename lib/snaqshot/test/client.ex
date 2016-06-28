defmodule Snaqshot.Test.Client do
  def create_snapshots(params \\ %{}, opts \\ [])

  def create_snapshots(params, opts) when is_map(params) and is_list(opts) do
    error_ret = Keyword.get(opts, :error_ret, 0)
    create_snapshots(:ret, error_ret)
  end

  def create_snapshots(:ret, 0) do
    {:ok, %{"action"    => "CreateSnapshotsResponse",
            "job_id"    => "j-" <> rand(:alpha, 6) <> rand(:digit, 2),
            "ret_code"  => 0,
            "snapshots" => ["ss-" <> rand(:alpha, 8)]}}
  end

  def create_snapshots(:ret, 1400) do
    msg = "PermissionDenied, " <>
          "you can create up to [2] snapshot chain for a resource"
    {:error, :status, %{"message" => msg, "ret_code" => 1400}}
  end

  def create_snapshots(:ret, :timeout) do
    {:error, :http, %HTTPoison.Error{id: nil, reason: :connect_timeout}}
  end

  defp rand(:alpha, count), do: Enum.take_random(?0..?9, count)
  defp rand(:digit, count), do: Enum.take_random(?a..?z, count)
end
