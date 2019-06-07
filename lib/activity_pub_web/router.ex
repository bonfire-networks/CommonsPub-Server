# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.Router do
  @moduledoc """
  ActivityPub router
  """
  use ActivityPubWeb, :router

  pipeline :activity_pub do
    plug(:accepts, ["activity+json", "json"])
  end

  scope "/", ActivityPubWeb do
    pipe_through(:activity_pub)
    get "/:id", ActivityPubController, :show
    get "/:id/page", ActivityPubController, :collection_page
    post "/shared_inbox", ActivityPubController, :shared_inbox, as: :shared_inbox
  end
end
