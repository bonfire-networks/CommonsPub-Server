# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ResourcesResolver do
  alias MoodleNet.{Collections, GraphQL, Repo, Resources}
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Batching.Edges
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Resources.Resource
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  def resource(%{resource_id: id}, %{context: %{current_user: user}}) do
    Resources.one(user: user, id: id)
  end

  def is_local_edge(%{collection: %Collection{actor: %Actor{peer_id: peer_id}}}, _, _) do
    {:ok, is_nil(peer_id)}
  end
  def is_local_edge(%{collection_id: id}, _, _) do
    batch {__MODULE__, :batch_is_local_edge}, id,
      fn edges ->
        ret =
          edges
          |> Map.get(id, %{})
          |> Map.get(:actor, %{})
          |> Map.get(:peer_id)
          |> is_nil()
        {:ok, ret}
      end
  end

  def batch_is_local_edge(_, ids) do
    {:ok, edges} = Collections.edges(&(&1.id), [:default, id: ids])
    edges
  end

  def collection_edge(%Resource{collection: %Collection{}=c}, _, _info), do: {:ok, c}
  def collection_edge(%Resource{collection_id: id}, _, _) do
    batch {__MODULE__, :batch_collection_edge}, id, Edges.getter(id)
  end

  def batch_collection_edge(_, ids) do
    {:ok, edges} = Collections.edges(&(&1.id), [:default, id: ids])
    edges
  end

  def create_resource(%{resource: attrs, collection_id: collection_id}, info) do
    with {:ok, current_user} <- GraphQL.current_user(info) do
      Repo.transact_with(fn ->
        with {:ok, collection} <- Collections.one([:default, user: current_user, id: collection_id]),
             {:ok, resource} <- Resources.create(current_user, collection, attrs) do
          {:ok, %{ resource | collection: collection } }
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
             attrs = Map.take(resource, ~w(name summary icon url license)a) do
          Resources.create(current_user, collection, attrs)
        end
      end)
    end
  end

  def last_activity_edge(_, _, _info), do: {:ok, DateTime.utc_now()}

end
