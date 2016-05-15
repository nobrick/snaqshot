defmodule Snaqshot.Client.URI do
  def encode_query(enum) do
    Enum.map_join(enum, "&", fn {k, v} -> encode(k) <> "=" <> encode(v) end)
  end

  defp encode(val) do
    val
    |> to_string
    |> URI.encode_www_form
    |> String.replace("+", "%20")
  end

  def relative_path(uri) do
    uri
    |> String.split("/")
    |> Enum.reject(&(&1 in ["https:", ""]))
    |> tl
    |> Enum.join("/")
    |> (&("/" <> &1 <> "/")).()
  end
end
