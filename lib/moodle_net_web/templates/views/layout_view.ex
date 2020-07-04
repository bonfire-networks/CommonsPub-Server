# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.LayoutView do
  use MoodleNetWeb, :view

  import MoodleNetWeb.Helpers.Common

  def app_name(), do: Application.get_env(:moodle_net, :app_name)
end
