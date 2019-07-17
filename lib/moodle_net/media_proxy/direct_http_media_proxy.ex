# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.DirectHTTPMediaProxy do
  alias MoodleNet.MediaProxy.URLBuilder

  @behaviour MoodleNet.MediaProxy

  @moduledoc """
  Fetches remote media using HTTP/HTTPS, without any caching being used.
  """

  def fetch(sig, url) do
    with {:ok, decoded_url} <- URLBuilder.decode(sig, url) do
      {:ok, 200, headers, client} = :hackney.get(decoded_url)
      content_type = headers |> Map.new() |> Map.get("Content-Type")
      {:ok, content_type, fetch_stream(client)}
    end
  end

  defp fetch_stream(client) do
    Stream.resource(
      fn -> client end,
      fn client ->
        case :hackney.stream_body(client) do
          {:ok, data} ->
            {[data], client}

          :done ->
            {:halt, client}
        end
      end,
      fn client -> :hackney.close(client) end
    )
  end
end
