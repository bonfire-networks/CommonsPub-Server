# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ResourcesResolver do
  alias MoodleNet.{Collections, GraphQL, Repo, Resources}
  alias MoodleNetWeb.GraphQL.{
    CollectionsResolver,
    CommonResolver,
    LocalisationResolver,
  }
  alias MoodleNet.Batching.{Edges, EdgesPages}
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Resources.Resource
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  def resource(%{resource_id: id}, %{context: %{current_user: user}}) do
    Resources.one(user: user, id: id)
  end

  def is_local_edge(%Resource{}=res, _, _), do: {:ok, true}
  def is_public_edge(%Resource{}=res, _, _), do: {:ok, not is_nil(res.published_at)}
  def is_disabled_edge(%Resource{}=res, _, _), do: {:ok, not is_nil(res.disabled_at)}

  def collection_edge(%Resource{collection: %Collection{}=c}, _, info), do: {:ok, c}
  def collection_edge(%Resource{collection_id: id}, _, %{context: %{current_user: user}}) do
    batch {__MODULE__, :batch_collection_edge, user}, id, Edges.getter(id)
  end

  def batch_collection_edge(current_user, ids) do
    {:ok, edges} = Collections.edges(&(&1.id), [:default, id: ids])
    edges
  end

  def create_resource(%{resource: attrs, collection_id: collection_id}, info) do
    with {:ok, current_user} <- GraphQL.current_user(info) do
      Repo.transact_with(fn ->
        with {:ok, collection} <- Collections.one([:default, user: current_user, id: collection_id]),
             {:ok, resource} <- Resources.create(current_user, collection, attrs) do
          is_local = is_nil(collection.actor.peer_id)
          {:ok, %{ resource | collection: collection, is_local: is_local } }
        end
      end)
    end
  end

  def update_resource(%{resource: changes, resource_id: resource_id}, info) do
    with {:ok, current_user} <- GraphQL.current_user(info) do
      Repo.transact_with(fn ->
        with {:ok, resource} <- resource(%{resource_id: resource_id}, info) do
          resource = Repo.preload(resource, [collection: :community])
          permitted? =
            current_user.local_user.is_instance_admin or
            resource.creator_id == current_user.id or
            resource.collection.creator_id == current_user.id or
            resource.collection.community.creator_id == current_user.id

          if permitted?,
            do: Resources.update(resource, changes),
            else: GraphQL.not_permitted()
        end
      end)
    end
  end

  def copy_resource(%{resource_id: resource_id, collection_id: collection_id}, info) do
    with {:ok, current_user} <- GraphQL.current_user(info) do
      Repo.transact_with(fn ->
        with {:ok, collection} <- Collections.one([:default, id: collection_id, user: current_user]),
             {:ok, resource} <- resource(%{resource_id: resource_id}, info),
             attrs = Map.take(resource, ~w(name summary icon url license)a),
             {:ok, resource} <- Resources.create(current_user, collection, attrs) do
          {:ok, Map.put(resource, :is_local, true)}
        end
      end)
    end
  end

  def last_activity_edge(_, _, info) do
    {:ok, DateTime.utc_now()}
  end

end
