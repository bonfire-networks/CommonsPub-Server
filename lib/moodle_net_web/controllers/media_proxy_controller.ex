# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.MediaProxyController do
  use MoodleNetWeb, :controller

  @proxy MoodleNet.DirectHTTPMediaProxy

  def remote(conn, %{"sig" => sig, "url" => url}) do
    {:ok, content_type, stream} = @proxy.fetch(sig, url)
    conn
    |> put_resp_content_type(content_type)
    |> send_chunked(200)
    |> stream_respond(stream)
  end

  # send a chunked http response using a stream
  defp stream_respond(conn, stream) do
    Enum.reduce_while(stream, conn, fn data, conn ->
      if data == :halt do
        {:halt, conn}
      else
        {:ok, conn} = chunk(conn, data)
        {:cont, conn}
      end
    end)
  end
end
