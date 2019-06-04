# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.OAuth.OAuthView do
  use MoodleNetWeb, :view

  def render("token.json", %{token: token}) do
    {:ok, inserted_at} = DateTime.from_naive(token.inserted_at, "Etc/UTC")
    created_at = DateTime.to_unix(inserted_at)
    %{
      token_type: "Bearer",
      access_token: token.hash,
      refresh_token: token.refresh_hash,
      expires_in: 60 * 10,
      created_at: created_at,
      scope: "read write follow"
    }
  end
end
