# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Gravatar do
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
