defmodule Snaqshot.Client do
  import Snaqshot.Client.Signature, only: [sign_into_query: 1]
  alias Calendar.DateTime

  @base Application.get_env(:snaqshot, :base_uri)
  @base_path Snaqshot.Client.URI.relative_path(@base)
  @access_key Application.get_env(:snaqshot, :access_key)
  @zone Application.get_env(:snaqshot, :zone)

  @doc """
  Get snaqshot descriptions.

  https://docs.qingcloud.com/api/snapshot/describe_snapshots.html
  """
  def describe_snapshots(params \\ %{}, opts \\ []) do
    get("DescribeSnapshots", params, opts)
  end

  @doc """
  Create snapshots.

  ## Required params

  * `resources`: The resources list for backup.

  ## Optional params

  * `snapshot_name`: The snapshot name.
  * `is_full`: Full or incremental backup. `true` for full backup, `false`
  otherwise.

  ## Example

      Snaqshot.Client.create_snapshots(%{resources: ["i-15ka", "vol-k9r"]})

  ## References

  https://docs.qingcloud.com/api/snapshot/create_snapshots.html
  """
  def create_snapshots(params \\ %{}, opts \\ []) do
    key_and_types = [{:resources, :list}, {:is_full, :boolean}]
    get("CreateSnapshots", normalize_params(params, key_and_types), opts)
  end

  @doc """
  Delete snapshots.

  ## Required params

  * `snapshots`: The ID list of snapshots to delete.

  ## Example

      Snaqshot.Client.delete_snapshots(%{snapshots: ~w(ss-88hr2kri)})

  ## References

  https://docs.qingcloud.com/api/snapshot/delete_snapshots.html
  """
  def delete_snapshots(params \\ %{}, opts \\ []) do
    key_and_types = [{:snapshots, :list}]
    get("DeleteSnapshots", normalize_params(params, key_and_types), opts)
  end

  def base_path do
    @base_path
  end

  defp get(action, params, opts \\ []) do
    dry_run = Keyword.get(opts, :dry_run, false)
    query = params |> Map.put(:action, action) |> pack_into_query
    uri = @base <> "?" <> query
    if dry_run do
      {:dry_run, uri}
    else
      case HTTPoison.get(uri) do
        {:ok, %{body: body}} -> normalize_json(body)
        {:error, reason}     -> {:error, :http, reason}
      end
    end
  end

  defp normalize_params(params, key_and_types) do
    Enum.reduce(key_and_types, params, fn {key, type}, acc ->
      {val, new_acc} = Map.pop(acc, key)
      if is_nil(val) do
        new_acc
      else
        Map.merge(new_acc, convert_to_params(type, key, val))
      end
    end)
  end

  defp convert_to_params(:boolean, k, true),  do: %{k => 1}
  defp convert_to_params(:boolean, k, false), do: %{k => 0}
  defp convert_to_params(:list, resource_name, list) do
    1..Enum.count(list)
    |> Enum.map(& "#{resource_name}.#{&1}")
    |> Enum.zip(list)
    |> Map.new
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
