# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CollectionsResolver do
  alias MoodleNet.{
    Collections,
    Communities,
    GraphQL,
    Instance,
    Repo,
    Resources,
  }
  alias MoodleNet.Batching.{Edges, EdgesPages}
  alias MoodleNet.Collections.Collection
  alias MoodleNetWeb.GraphQL.CommunitiesResolver
  import Absinthe.Resolution.Helpers, only: [batch: 3]
  use MoodleNet.Common.Metadata

  def collection(%{collection_id: id}, %{context: %{current_user: user}}) do
    Collections.one(
      user: user,
      id: id,
      join: :actor,
      preload: :actor
    )
  end

  def collections(_args, %{context: %{current_user: user}}) do
    Collections.nodes_page(
      &(&1.id),
      [user: user],
      [join: {:actor, :left},
       join: :follower_count,
       order: :followers_desc,
       preload: :follower_count]
    )
  end

  def canonical_url_edge(%Collection{id: id, actor: %{canonical_url: nil}}, _, _) do
    {:ok, Instance.base_url() <> "/collections/" <> id}
  end
  def canonical_url_edge(%Collection{actor: %{canonical_url: url}}, _, _) do
    {:ok, url}
  end

  def resource_count_edge(%Collection{id: id}, _, _info) do
    batch {__MODULE__, :batch_resource_count_edge}, id,
      fn edges ->
        case Map.get(edges, id) do
          [{_, count}] -> {:ok, count}
          _ -> {:ok, 0}
        end
      end
  end

  def batch_resource_count_edge(_, ids) do
    {:ok, edges} = Resources.many(
      collection_id: ids,
      group_count: :collection_id
    )
    Enum.group_by(edges, fn {id, _} -> id end)
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
      [order: :timeline_desc],
      [group_count: :collection_id]
    )
    edges
  end

  def community_edge(%Collection{community_id: id}, _, _info) do
    batch {__MODULE__, :batch_community_edge}, id, Edges.getter(id)
  end

  def batch_community_edge(_, ids) do
    {:ok, edges} = Communities.edges(&(&1.id), [:default, id: ids])
    edges
  end

  def last_activity_edge(_, _, _info) do
    {:ok, DateTime.utc_now()}
  end

  def outbox_edge(%Collection{}=coll, _, _info) do
    Collections.outbox(coll)
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
