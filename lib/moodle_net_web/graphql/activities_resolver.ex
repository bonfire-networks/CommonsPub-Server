# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ActivitiesResolver do
  alias MoodleNet.Activities
  alias MoodleNet.Activities.Activity
  alias MoodleNet.GraphQL.{Fields, ResolveFields}
  alias MoodleNet.Meta.Pointers
  
  def activity(%{activity_id: id}, %{context: %{current_user: user}}) do
    Activities.one(id: id, user: user)
  end

  def context_edge(%Activity{context: context}, _, info) do
    ResolveFields.run(
      %ResolveFields{
        module: __MODULE__,
        fetcher: :fetch_context_edge,
        context: context,
        info: info,
      }
    )
  end

  def fetch_context_edge(_, contexts) do
    Fields.new(Pointers.follow!(contexts), &(&1.id))
  end

end
