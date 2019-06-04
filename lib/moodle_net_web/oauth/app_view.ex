# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.OAuth.AppView do
  use MoodleNetWeb, :view

  def render("app.json", %{app: app}) do
    Map.take(app, [:client_name, :redirect_uri, :scopes, :website, :client_id, :client_secret])
  end
end
