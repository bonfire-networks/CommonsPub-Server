# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ActivitiesResolver do
  alias MoodleNet.{Fake, GraphQL, Repo}
  alias MoodleNet.Activities.Activity
  
  def activity(%{activity_id: id}, info) do
    Activities.fetch(id)
  end

  def user(%Activity{}=parent, _, info) do
    {:ok, Repo.preload(parent, [creator: :actor]).creator}
  end

end
