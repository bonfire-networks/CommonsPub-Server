# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.LayoutView do
  use MoodleNetWeb, :view

  defp logo_url() do
    path = MoodleNetWeb.Endpoint.static_path("/images/moodlenet-logo.png")

    MoodleNetWeb.Endpoint.struct_url()
    |> Map.put(:path, path)
    |> URI.to_string()
  end
end
