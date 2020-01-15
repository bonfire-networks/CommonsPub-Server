# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ActivitiesResolver do
  alias MoodleNet.{Activities, Fake, GraphQL, Repo}
  alias MoodleNet.Activities.Activity
  alias MoodleNet.Batching.Edges
  alias MoodleNet.Feeds.FeedActivity
  alias MoodleNet.Meta.Pointers
  alias MoodleNet.Users
  import Absinthe.Resolution.Helpers, only: [batch: 3]
  
  def activity(%{activity_id: id}, %{context: %{current_user: user}}) do
    Activities.one(id: id, user: user)
  end

  def user_edge(%FeedActivity{activity: %Activity{creator_id: id}}, _, %{context: %{current_user: user}}) do
    batch {__MODULE__, :batch_user_edge, user}, id, Edges.getter(id)
  end

  def batch_user_edge(user, ids) do
    {:ok, edges} = Users.edges(&(&1.id), id: ids, user: user)
    edges
  end

  def verb_edge(%FeedActivity{activity: %Activity{verb: verb}}, _, _info), do: {:ok, verb}


  def context_edge(%FeedActivity{activity: %Activity{context: context}}, _, %{context: %{current_user: user}}) do
    batch {__MODULE__, :batch_context_edge, user}, context, Edges.getter(context.id)
  end

  def batch_context_edge(user, contexts) do
    Edges.new(Pointers.follow!(contexts), &(&1.id))
  end

end
