# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.LayoutView do
  use MoodleNetWeb, :view

  import MoodleNetWeb.Helpers.Common

  def app_name(), do: Application.get_env(:moodle_net, :app_name)
end
