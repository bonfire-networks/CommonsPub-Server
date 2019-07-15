# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.MediaProxy do
  @callback fetch(sig :: String.t(), url :: String.t()) :: {:ok, Stream.t()} | {:error, term}
end

defmodule MoodleNet.DirectHTTPMediaProxy do
  alias MoodleNet.MediaProxy.URLBuilder

  @behaviour MoodleNet.MediaProxy

  def fetch(sig, url) do
    with {:ok, decoded_url} <- URLBuilder.decode(sig, url) do
      {:ok, 200, _headers, client} = :hackney.get(decoded_url)
      {:ok, fetch_stream(client)}
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
