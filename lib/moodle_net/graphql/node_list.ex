# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.GraphQL.NodeList do
  @enforce_keys [:page_info, :nodes]
  defstruct [:total_count | @enforce_keys]
end
