# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.SQLActivityAspect do
  @moduledoc """
  `ActivityPub.SQLAspect` for `ActivityPub.ActivityAspect`
  """

  use ActivityPub.SQLAspect,
    aspect: ActivityPub.ActivityAspect,
    persistence_method: :table,
    table_name: "activity_pub_activity_aspects"
end
