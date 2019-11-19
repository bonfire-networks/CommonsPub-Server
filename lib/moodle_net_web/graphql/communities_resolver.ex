# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommunitiesResolver do
  @moduledoc """
  Performs the GraphQL Community queries.
  """
  import Ecto.Query
  alias Absinthe.Relay
  alias MoodleNet.{
    Accounts,
    Actors,
    Common,
    Collections,
    Communities,
    Fake,
    GraphQL,
    Repo,
    Users,
  }
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Communities.Community
  alias MoodleNet.Collections.Collection

  def community(%{community_id: id}, info), do: Communities.fetch(id)

  def communities(args, info) do
    Repo.transact_with(fn ->
      count = Communities.count_for_list()
      comms = Communities.list()
      {:ok, GraphQL.node_list(comms, count)}
    end)
  end

  def create_community(%{community: attrs}, info) do
    with {:ok, user} <- GraphQL.current_user(info) do
      Communities.create(user, attrs)
    end
  end

  def update_community(%{community: changes, community_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user(info),
           {:ok, community} <- Communities.fetch_private(id) do
        cond do
          user.local_user.is_instance_admin ->
            Communities.update(community, changes)

	  community.creator_id == user.id ->
            Communities.update(community, changes)

	  is_nil(community.published_at) -> GraphQL.not_found()

	  true -> GraphQL.not_permitted()
    	end
      end
    end)
  end

  # def delete(%{community_id: id}, info) do
  #   Repo.transact_with(fn ->
  #     with {:ok, user} <- GraphQL.current_user(info),
  #          {:ok, actor} <- Users.fetch_actor(user),
  #          {:ok, community} <- Communities.fetch(id) do
  #       if community.creator_id == actor.id do
  # 	  with {:ok, _} <- Communities.soft_delete(community), do: {:ok, true}
  #       else
  #         GraphQL.not_permitted()
  #       end
  #     end
  #   end)
  #   |> GraphQL.response(info)
  # end

  def canonical_url(%Community{}=community, _, info) do
    {:ok, community.actor.canonical_url}
  end
  def preferred_username(%Community{}=community, _, info) do
    {:ok, community.actor.preferred_username}
  end

  def is_local(%Community{}=community, _, info) do
    {:ok, is_nil(community.actor.peer_id)}
  end

  def collections(%Community{}=community, _, info) do
    Repo.transact_with(fn ->
      count = Collections.count_for_list_in_community(community)
      comms = Collections.list_in_community(community)
      {:ok, GraphQL.edge_list(comms, count, &(&1.created_at))}
    end)
  end

  def inbox(community, _, info) do
    activities = Fake.long_list(&Fake.activity/0)
    count = Fake.pos_integer()
    {:ok, GraphQL.edge_list(activities, count)}
    |> GraphQL.response(info)    
  end

  def outbox(community, _, info) do
    activities = Fake.long_list(&Fake.activity/0)
    count = Fake.pos_integer()
    {:ok, GraphQL.edge_list(activities, count)}
    |> GraphQL.response(info)
  end

  def last_activity(_, _, info) do
    {:ok, Fake.past_datetime()}
    |> GraphQL.response(info)
  end

end
