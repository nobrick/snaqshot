defmodule Snaqshot.ClientTest do
  import Snaqshot.Client, only: [describe_snapshots: 0]
  use ExUnit.Case, async: true
  doctest Snaqshot

  test "#describe_snapshots" do
    assert {:ok, %{"ret_code" => _, "snapshot_set" => _}} = describe_snapshots
  end
end
