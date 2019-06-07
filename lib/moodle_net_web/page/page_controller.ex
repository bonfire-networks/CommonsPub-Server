# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.PageController do
  @moduledoc """
  Standard page controller created by Phoenix generator
  """
  use MoodleNetWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
