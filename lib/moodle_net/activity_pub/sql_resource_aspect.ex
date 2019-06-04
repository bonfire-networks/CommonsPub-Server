# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.AP.SQLResourceAspect do
  use ActivityPub.SQLAspect,
    aspect: MoodleNet.AP.ResourceAspect,
    persistence_method: :table,
    table_name: "activity_pub_resource_aspects"
end
