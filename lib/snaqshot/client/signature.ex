defmodule Snaqshot.Client.Signature do
  import Snaqshot.Client.URI, only: [encode_query: 1]
  import URI, only: [encode_www_form: 1]
  alias Snaqshot.Client

  @secret_key Application.get_env(:snaqshot, :secret_key)

  def with_signature(params, opts \\ []) do
    hash = %{signature_method: "HmacSHA256", signature_version: 1}
    params = Map.merge(params, hash)
    Map.put(params, :signature, params |> to_query |> sign(opts))
  end

  def sign(query, opts \\ []) do
    method = Keyword.get(opts, :req_method, "GET")
    path   = Keyword.get(opts, :base_path, Client.base_path)
    secret_key = Keyword.get(opts, :secret_key, @secret_key)
    "#{method}\n#{path}\n#{query}" |> hmac(secret_key)
  end

  defp hmac(str, key, type \\ :sha256) do
    :crypto.hmac(type, key, str)
    |> Base.encode64
    |> encode_www_form
  end

  defp to_query(params) do
    params
    |> Enum.sort_by(& to_string(elem &1, 0))
    |> encode_query
  end
end
