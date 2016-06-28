defmodule Snaqshot.BackupWorker do
  use GenServer
  import Snaqshot.Client, only: [create_snapshots: 2]
  import Logger, only: [debug: 1]

  @resources Application.get_env(:snaqshot, :workers)
             |> Keyword.get(:resources)

  def start_link(perf_args \\ {%{}, []}, opts \\ []) do
    GenServer.start_link(__MODULE__, perf_args, opts)
  end

  def perform(pid \\ __MODULE__) do
    GenServer.call(pid, :perform, 8000)
  end

  def init({_params, _opts} = perf_args) do
    debug "#{__MODULE__} inited."
    {:ok, %{perf_args: perf_args, ret: nil}}
  end

  def handle_call(:perform, _from, %{perf_args: {params, opts}} = state) do
    {:ok, job_id, snapshots} = ret = do_perform(params, opts)
    {:reply, ret, %{state|ret: {job_id, snapshots}}}
  end

  def do_perform(params \\ %{}, opts \\ [])
      when is_map(params) and is_list(opts) do
    params = params |> Map.put_new(:resources, @resources)
    debug "#{__MODULE__} is peforming backup with #{inspect(params)}."
    case create_snapshots(params, opts) do
      {:dry_run, _} = ret ->
        ret
      {:ok, ret} ->
        handle_resp(:ok, ret)
      {:error, :status, %{"ret_code" => 1400}} = err ->
        Logger.error(inspect(err))
    end
  end

  defp handle_resp(:ok, %{"action" => "CreateSnapshotsResponse",
                      "job_id" => job_id,
                      "ret_code" => 0,
                      "snapshots" => snapshots} = ret) do
    debug inspect(ret)
    {:ok, job_id, snapshots}
  end
end
