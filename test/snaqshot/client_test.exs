defmodule Snaqshot.ClientTest do
  import Snaqshot.Client, only: [describe_snapshots: 0, create_snapshots: 2,
                                 delete_snapshots: 2]
  use ExUnit.Case, async: true

  setup do
    params = %{
      access_key_id: "QYACCESSKEYIDEXAMPLE",
      time_stamp: "2013-08-27T14:30:10Z",
      zone: "gd1"
    }
    {:ok, %{params: params}}
  end

  test "#describe_snapshots" do
    assert {:ok, %{"ret_code" => _, "snapshot_set" => _}} = describe_snapshots
  end

  test "#create_snapshots", %{params: params_mock} do
    params = Map.put(params_mock, :resources, ~w(ra1 rb1))
    {:dry_run, ret} = create_snapshots(params, [dry_run: true])
    expected = "https://api.qingcloud.com/iaas/?access_key_id=QYACCESSKEYIDEXAMPLE&action=CreateSnapshots&resources.1=ra1&resources.2=rb1&signature_method=HmacSHA256&signature_version=1&time_stamp=2013-08-27T14%3A30%3A10Z&version=1&zone=gd1&signature="
    assert String.starts_with?(ret, expected)
  end

  test "#delete_snapshots", %{params: params_mock} do
    params = Map.put(params_mock, :snapshots, ~w(ra1 rb1))
    {:dry_run, ret} = delete_snapshots(params, [dry_run: true])
    expected = "https://api.qingcloud.com/iaas/?access_key_id=QYACCESSKEYIDEXAMPLE&action=DeleteSnapshots&signature_method=HmacSHA256&signature_version=1&snapshots.1=ra1&snapshots.2=rb1&time_stamp=2013-08-27T14%3A30%3A10Z&version=1&zone=gd1&signature=LbXZ14cevSRjRnS%2FF7E%2BMSnoUsYDnXk%2FiVGP0zcsgEk%3D"
    assert String.starts_with?(ret, expected)
  end
end
