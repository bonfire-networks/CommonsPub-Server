# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CollectionsResolver do
  alias MoodleNet.{
    Batching,
    Collections,
    Common,
    Communities,
    GraphQL,
    Repo,
    Resources,
    Users,
  }
  alias MoodleNet.Batching.{Edges, EdgesPages, NodesPage}
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.Resources.Resosurce
  alias MoodleNet.Users.User
  alias MoodleNetWeb.GraphQL.{CommunitiesResolver, UsersResolver}
  import Absinthe.Resolution.Helpers, only: [batch: 3]
  use MoodleNet.Common.Metadata

  def collection(%{collection_id: id}, %{context: %{current_user: user}}) do
    Collections.one(user: user, id: id, join: :follower_count, preload: :actor)
  end

  def collections(_args, %{context: %{current_user: user}}) do
    Collections.nodes_page(
      &(&1.id),
      [user: user],
      [join: :follower_count, order: :followers_desc, preload: :follower_count]
    )
  end

  @will_break_when :pagination
  def resources_edge(%Collection{id: id}, _, %{context: %{current_user: user}}) do
    batch {__MODULE__, :batch_resources_edge, user}, id, EdgesPages.getter(id)
  end

  def batch_resources_edge(user, ids) do
    {:ok, edges} = Resources.edges_pages(
      &(&1.collection_id),
      &(&1.id),
      [user: user, collection_id: ids],
      [order: :timeline_asc],
      [group_count: :collection_id]
    )
    edges
  end

  def community_edge(%Collection{}=coll, _, info) do
    {:ok, Repo.preload(coll, [community: :actor]).community}
  end

  def last_activity_edge(_, _, info) do
    {:ok, Fake.past_datetime()}
    |> GraphQL.response(info)
  end

  def outbox_edge(%Collection{outbox_id: id}, _, %{context: %{current_user: user}}) do
    batch {__MODULE__, :batch_outbox_edge, user}, id, EdgesPages.getter(id)
  end

  def batch_outbox_edge(user, ids) do
    {:ok, edges} = FeedActivities.edges_pages(&(&1.feed_id), &(&1.id), id: ids)
    edges
  end

  ## finally the mutations...

  def create_collection(%{collection: attrs, community_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user(info),
           {:ok, community} <- CommunitiesResolver.community(%{community_id: id}, info) do
        attrs = Map.merge(attrs, %{is_public: true})
        Collections.create(user, community, attrs)
      end
    end)
  end

  def update_collection(%{collection: changes, collection_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user(info),
           {:ok, collection} <- collection(%{collection_id: id}, info) do
        collection = Repo.preload(collection, :community)
        cond do
          user.local_user.is_instance_admin ->
	    Collections.update(collection, changes)

          collection.creator_id == user.id ->
	    Collections.update(collection, changes)

          collection.community.creator_id == user.id ->
	    Collections.update(collection, changes)

          true -> GraphQL.not_permitted("update")
        end
      end
    end)
  end

  # def delete(%{collection_id: id}, info) do
  #   # Repo.transact_with(fn ->
  #   #   with {:ok, user} <- GraphQL.current_user(info),
  #   #        {:ok, actor} <- Users.fetch_actor(user),
  #   #        {:ok, collection} <- Collections.fetch(id) do
  #   #     collection = Repo.preload(collection, :community)
  #   # 	permitted =
  #   # 	  user.is_instance_admin or
  #   #       collection.creator_id == actor.id or
  #   #       collection.community.creator_id == actor.id
  #   # 	if permitted do
  #   # 	  with {:ok, _} <- Collections.soft_delete(collection), do: {:ok, true}
  #   # 	else
  #   # 	  GraphQL.not_permitted()
  #   #     end
  #   #   end
  #   # end)
  #   # |> GraphQL.response(info)
  #   {:ok, true}
  #   |> GraphQL.response(info)
  # end

end
