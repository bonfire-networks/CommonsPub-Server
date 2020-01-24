# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ActivitiesResolver do
  alias MoodleNet.Activities
  alias MoodleNet.Activities.Activity
  alias MoodleNet.Batching.Edges
  alias MoodleNet.Meta.Pointers
  import Absinthe.Resolution.Helpers, only: [batch: 3]
  
  def activity(%{activity_id: id}, %{context: %{current_user: user}}) do
    Activities.one(id: id, user: user)
  end

  def context_edge(%Activity{context: context}, _, _) do
    batch {__MODULE__, :batch_context_edge}, context, Edges.getter(context.id)
  end

  def batch_context_edge(_, contexts) do
    Edges.new(Pointers.follow!(contexts), &(&1.id))
  end

end
