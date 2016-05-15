defmodule Snaqshot.Client do
  import Snaqshot.Client.Signature, only: [sign_into_query: 1]
  alias Calendar.DateTime

  @base Application.get_env(:snaqshot, :base_uri)
  @base_path Snaqshot.Client.URI.relative_path(@base)
  @access_key Application.get_env(:snaqshot, :access_key)
  @zone Application.get_env(:snaqshot, :zone)

  def describe_snapshots(params \\ %{}) do
    get("DescribeSnapshots", params)
  end

  def base_path do
    @base_path
  end

  defp get(action, params \\ %{}) do
    query = params |> Map.put(:action, action) |> pack_into_query
    uri = @base <> "?" <> query
    case HTTPoison.get(uri) do
      {:ok, %{body: body}} -> normalize_json(body)
      {:error, reason}     -> {:error, :http, reason}
    end
  end

  defp normalize_json(json) do
    result = Poison.Parser.parse!(json)
    case result do
      %{"ret_code" => 0} -> {:ok, result}
      _                  -> {:error, :status, result}
    end
  end

  defp pack_into_query(params) do
    params
    |> with_timestamp
    |> with_access_key
    |> with_version
    |> with_zone
    |> sign_into_query
  end

  defp with_timestamp(params) do
    Map.put_new_lazy(params, :time_stamp, &time_now/0)
  end

  defp with_access_key(params) do
    Map.put_new(params, :access_key_id, @access_key)
  end

  defp with_version(params) do
    Map.put_new(params, :version, 1)
  end

  defp with_zone(params) do
    Map.put_new(params, :zone, @zone)
  end

  defp time_now do
    DateTime.now_utc
    |> DateTime.Format.iso8601
    |> String.slice(0..-9)
    |> (&(&1 <> "Z")).()
  end
end
