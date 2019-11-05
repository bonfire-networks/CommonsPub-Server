# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.MRF.NoOpPolicy do
  @moduledoc "Does nothing (lets the messages go through unmodified)"
  @behaviour ActivityPub.MRF

  @impl true
  def filter(object) do
    {:ok, object}
  end
end
