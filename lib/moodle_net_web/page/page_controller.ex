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
    url = Application.get_env(:moodle_net, :frontend_base_url)
    conn
    |> put_status(:moved_permanently)
    |> redirect(external: url)
  end
end
