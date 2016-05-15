defmodule Snaqshot.Client.SignatureTest do
  use ExUnit.Case, async: true
  import Snaqshot.Client.Signature, only: [sign: 2, sign_into_query: 2]
  doctest Snaqshot

  setup do
    params = %{
      "count": 1,
      "vxnets.1": "vxnet-0",
      "zone": "pek1",
      "instance_type": "small_b",
      "instance_name": "demo",
      "image_id": "centos64x86a",
      "login_mode": "passwd",
      "login_passwd": "QingCloud20130712",
      "version": 1,
      "access_key_id": "QYACCESSKEYIDEXAMPLE",
      "action": "RunInstances",
      "time_stamp": "2013-08-27T14:30:10Z"
    }
    secret = "SECRETACCESSKEY"
    {:ok, %{params: params, secret: secret}}
  end

  test "#sign", %{params: params, secret: secret} do
    signature = sign(params, secret_key: secret)
    assert signature == "32bseYy39DOlatuewpeuW5vpmW51sD1A%2FJdGynqSpP8%3D"
  end

  test "#sign_into_query", %{params: params, secret: secret} do
    query = sign_into_query(params, secret_key: secret)
    assert query == "access_key_id=QYACCESSKEYIDEXAMPLE&action=RunInstances&count=1&image_id=centos64x86a&instance_name=demo&instance_type=small_b&login_mode=passwd&login_passwd=QingCloud20130712&signature_method=HmacSHA256&signature_version=1&time_stamp=2013-08-27T14%3A30%3A10Z&version=1&vxnets.1=vxnet-0&zone=pek1&signature=32bseYy39DOlatuewpeuW5vpmW51sD1A%2FJdGynqSpP8%3D"
  end
end
