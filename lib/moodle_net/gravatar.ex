defmodule MoodleNet.Gravatar do
  @moduledoc """
  Gravatar utils
  """
  @uri %URI{
    scheme: "https",
    host: "s.gravatar.com",
    query: "d=identicon&r=g&s=80"
  }

  def url(email) when is_binary(email) do
    %{@uri | path: path(email)} |> URI.to_string()
  end

  defp path(email), do: "/avatar/#{hash(email)}"

  defp hash(email),
    do: :crypto.hash(:md5, String.downcase(email)) |> Base.encode16(case: :lower)
end
