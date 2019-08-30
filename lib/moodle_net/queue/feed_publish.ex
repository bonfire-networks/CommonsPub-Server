# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Queue.FeedPublishQueue do
  @moduledoc """
  """
  use Ecto.Schema
  alias Ecto.Changeset
  import MoodleNet.Queue

  schema "mn_queue_feed" do
    queue_fields()
  end

end
