# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.ObjectView do
  use ActivityPubWeb, :view

  alias ActivityPub.Utils

  def render("object.json", %{object: object}) do
    base = Utils.make_json_ld_header()

    Map.merge(base, object.data)
  end
end
