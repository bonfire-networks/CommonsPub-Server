# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.MediaProxy do
  @callback fetch(url :: String.t()) :: {:ok, File.t()} | {:error, term}
end

# defmodule MoodleNet.DirectHTTPMediaProxy do
#   alias MoodleNet.MediaProxy.URLBuilder

#   @behaviour MoodleNet.MediaProxy

#   def fetch(url) do
#     decoded_url = URLBuilder.decode(url)
#     {:ok, status, headers, client} = :hackney.get(decoded_url)
#     {:ok, content} = :hackney.body(client)
#     {:ok, content}
#   end
# end
