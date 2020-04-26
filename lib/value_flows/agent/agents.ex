# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Agent.Agents do

  alias ValueFlows.{Simulate}
  require Logger



  def actor_to_agent(a) do
    a 
    |> ValueFlows.Util.maybe_put(:note, a.summary)
    # |> ValueFlows.Util.maybe_put(:note, a.summary)
  end


end
