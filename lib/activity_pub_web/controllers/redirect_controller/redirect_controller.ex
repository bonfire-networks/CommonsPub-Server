# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.RedirectController do
  @moduledoc """
  Redirects canonical URLs to the appropriate page in the LiveView frontend
  """

  use ActivityPubWeb, :controller

  def object(conn, %{"uuid" => uuid}) do
    if System.get_env("LIVEVIEW_ENABLED", "true") == "true" do
      ActivityPubWeb.RedirectController.LiveView.object(conn, %{"uuid" => uuid})
    else
      ActivityPubWeb.RedirectController.React.object(conn, %{"uuid" => uuid})
    end
  end

  def actor(conn, %{"username" => username}) do
    if System.get_env("LIVEVIEW_ENABLED", "true") == "true" do
      ActivityPubWeb.RedirectController.LiveView.actor(conn, %{"username" => username})
    else
      ActivityPubWeb.RedirectController.React.actor(conn, %{"username" => username})
    end
  end
end
