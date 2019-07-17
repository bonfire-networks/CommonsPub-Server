# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.ActivityPubView do
  @moduledoc """
  Even though store the data in AS format, some changes need to be applied to the entity before serving it in the AP REST response. This is done in this module.
  """

  use ActivityPubWeb, :view

  def render("show.json", %{entity: entity, conn: _conn}) do
    ActivityPubWeb.Transmogrifier.prepare_outgoing(entity)
  end
end
