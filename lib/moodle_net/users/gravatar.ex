# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.Gravatar do
  @moduledoc """
  Gravatar utils
  """

  def url(email) do
    url(email, "retro", 80)
  end

  def url(email, style, width) when is_binary(email) do
    uri = %URI{
      scheme: "https",
      host: "s.gravatar.com",
      query: "d=" <> style <> "&r=g&s=" <> to_string(width),
      path: path(email)
    }

    uri |> URI.to_string()
  end

  defp path(email), do: "/avatar/#{hash(email)}"

  defp hash(email),
    do: :crypto.hash(:md5, String.downcase(email)) |> Base.encode16(case: :lower)
end
