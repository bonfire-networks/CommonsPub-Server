# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommunitiesResolver do
  @moduledoc """
  Performs the GraphQL Community queries.
  """
  import Ecto.Query
  alias Absinthe.Resolution
  alias MoodleNet.Fake
  alias MoodleNet.{Accounts, Actors, Common, Collections, Communities, Fake, GraphQL, Repo, Users}
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Communities.Community
  alias MoodleNet.Collections.Collection

  def community(%{community_id: id}, info) do
    # with {:ok, {community, actor}} <- Repo.single(fetch_q(id)) do
    #   {:ok, %{community | actor: Actors.preload(actor)}}
    # end
    {:ok, Fake.community()}
    |> GraphQL.response(info)
  end

  def community(_, _, info) do
    # with {:ok, {community, actor}} <- Repo.single(fetch_q(id)) do
    #   {:ok, %{community | actor: Actors.preload(actor)}}
    # end
    # |> GraphQL.response(info)
    {:ok, Fake.community()}
    |> GraphQL.response(info)
  end

  def communities(_args, info) do
    # Repo.transact_with(fn ->
    #   count = Communities.count_for_list()
    #   comms = Communities.list()
    #   {:ok, GraphQL.node_list(comms, count)}
    # end)
    # count = Fake.pos_integer()
    # comms = Fake.long_list(&Fake.collection/0)
    # {:ok, GraphQL.node_list(comms, count)}
    {:ok, Fake.long_node_list(&Fake.community/0)}
    |> GraphQL.response(info)
  end

  # defp fetch_q(id) do
  #   from c in Community,
  #     join: a in Actor, on: c.id == a.alias_id,
  #     where: a.id == ^id,
  #     where: is_nil(c.deleted_at),
  #     where: is_nil(a.deleted_at),
  #     where: not is_nil(c.published_at),
  #     where: not is_nil(a.published_at),
  #     select: {c, a}
  # end

  def create_community(%{community: attrs}, info) do
    # with {:ok, user} <- GraphQL.current_user(info),
    #      {:ok, actor} <- Users.fetch_actor(user) do
    #   Communities.create(user, actor, attrs)
    # end
    # |> GraphQL.response(info)
    {:ok, Fake.community()}
    |> GraphQL.response(info)
  end

  def update_community(%{community: changes, community_id: id}, info) do
    # Repo.transact_with(fn ->
    #   with {:ok, user} <- GraphQL.current_user(info),
    #        {:ok, actor} <- Users.fetch_actor(user),
    #        {:ok, community} <- Communities.fetch(id) do
    #     if community.creator_id == actor.id do
    #       Communities.update(community, changes)
    #     else
    #       GraphQL.not_permitted()
    # 	end
    #   end
    # end)
    # |> GraphQL.response(info)
    {:ok, Fake.community()}
    |> GraphQL.response(info)
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
