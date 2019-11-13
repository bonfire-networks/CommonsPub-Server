# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.GraphQL.EdgeList do
  @enforce_keys [:page_info, :edges]
  defstruct [:total_count | @enforce_keys]
end
