defmodule Snaqshot.Client do
  import Snaqshot.Client.Signature, only: [with_signature: 1]
  alias Calendar.DateTime

  @base Application.get_env(:snaqshot, :base_uri)
  @base_path Snaqshot.Client.URI.relative_path(@base)
  @access_key Application.get_env(:snaqshot, :access_key)
  @zone Application.get_env(:snaqshot, :zone)

  def describe_snapshots do
  end

  def base_path do
    @base_path
  end

  def get(%{action: _action} = params) do
    pack_params(params)
  end

  defp pack_params(params) do
    params
    |> with_timestamp
    |> with_access_key
    |> with_version
    |> with_zone
    |> with_signature
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
