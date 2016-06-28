defmodule Snaqshot.BackupWorkerTest do
  use ExUnit.Case
  alias Snaqshot.BackupWorker

  setup do
    params = %{
      access_key_id: "QYACCESSKEYIDEXAMPLE",
      time_stamp: "2013-08-27T14:30:10Z",
      zone: "gd1"
    }
    {:ok, %{params: params}}
  end

  test "creates a snaqshot", %{params: params_mock} do
    {:dry_run, ret} = BackupWorker.perform(params_mock, [dry_run: true])
    expected = "https://api.qingcloud.com/iaas/?access_key_id=QYACCESSKEYIDEXAMPLE&action=CreateSnapshots&resources.1=i-vvt81pur&signature_method=HmacSHA256&signature_version=1&time_stamp=2013-08-27T14%3A30%3A10Z&version=1&zone=gd1"
    assert String.starts_with?(ret, expected)
  end
end
