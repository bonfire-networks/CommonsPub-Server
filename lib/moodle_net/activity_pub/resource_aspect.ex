# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.AP.ResourceAspect do
  use ActivityPub.Aspect, persistence: MoodleNet.AP.SQLResourceAspect

  aspect do
    field(:same_as, :string)
    field(:in_language, :string, functional: false)
    field(:public_access, :boolean, default: true)
    field(:is_accesible_for_free, :boolean, default: true)
    field(:license, :string)
    field(:learning_resource_type, :string)
    field(:educational_use, :string, functional: false)
    field(:time_required, :integer)
    field(:typical_age_range, :string)
    field(:primary_language, :string)
  end
end
