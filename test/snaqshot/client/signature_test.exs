defmodule Snaqshot.Client.SignatureTest do
  use ExUnit.Case, async: true
  import Snaqshot.Client.Signature, only: [with_signature: 2]
  doctest Snaqshot

  test "#with_signature" do
    params = %{
      "count": 1,
      "vxnets.1": "vxnet-0",
      "zone": "pek1",
      "instance_type": "small_b",
      "signature_version": 1,
      "signature_method": "HmacSHA256",
      "instance_name": "demo",
      "image_id": "centos64x86a",
      "login_mode": "passwd",
      "login_passwd": "QingCloud20130712",
      "version": 1,
      "access_key_id": "QYACCESSKEYIDEXAMPLE",
      "action": "RunInstances",
      "time_stamp": "2013-08-27T14:30:10Z"
    }
    secret_key = "SECRETACCESSKEY"
    %{signature: signature} = with_signature(params, secret_key: secret_key)
    assert signature == "32bseYy39DOlatuewpeuW5vpmW51sD1A%2FJdGynqSpP8%3D"
  end
end
