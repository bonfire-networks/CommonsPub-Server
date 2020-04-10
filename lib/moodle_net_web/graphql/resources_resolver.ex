# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ResourcesResolver do
  alias MoodleNet.{Collections, GraphQL, Repo, Resources, Uploads}
  alias MoodleNet.Actors.Actor
  alias MoodleNet.GraphQL.Flow
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Uploads.{IconUploader, ResourceUploader}
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  def resource(%{resource_id: id}, info) do
    Resources.one(id: id, user: GraphQL.current_user(info))
  end

  def is_local_edge(%{collection: %Collection{actor: %Actor{peer_id: peer_id}}}, _, _) do
    {:ok, is_nil(peer_id)}
  end
  def is_local_edge(%{collection_id: id}, _, _) do
    batch {__MODULE__, :fetch_is_local_edge}, id,
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

  def fetch_is_local_edge(_, ids) do
    {:ok, fields} = Collections.fields(&(&1.id), [:default, id: ids])
    fields
  end

  def collection_edge(%Resource{collection: %Collection{}=c}, _, _info), do: {:ok, c}
  def collection_edge(%Resource{collection_id: id}, _, info) do
    Flow.fields __MODULE__, :fetch_collection_edge, id, info
  end

  def fetch_collection_edge(_, ids) do
    {:ok, fields} = Collections.fields(&(&1.id), [:default, id: ids])
    fields
  end

  def create_resource(%{resource: attrs, collection_id: collection_id, content: content_file}, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
      Repo.transact_with(fn ->
        with {:ok, content} <- Uploads.upload(ResourceUploader, user, content_file, %{}),
             {:ok, collection} <- Collections.one([:default, user: user, id: collection_id]),
             attrs = Map.put(attrs, :content_id, content.id),
             {:ok, resource} <- Resources.create(user, collection, attrs) do
          {:ok, %{ resource | collection: collection, content: content } }
        end
      end)
    end
  end

  def update_resource(%{resource: changes, resource_id: resource_id}, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
      Repo.transact_with(fn ->
        with {:ok, resource} <- resource(%{resource_id: resource_id}, info) do
          resource = Repo.preload(resource, [collection: :community])
          permitted? =
            user.local_user.is_instance_admin or
            resource.creator_id == user.id or
            resource.collection.creator_id ==user.id or
            resource.collection.community.creator_id == user.id

          if permitted?,
            do: Resources.update(resource, changes),
            else: GraphQL.not_permitted()
        end
      end)
    end
  end

  def copy_resource(%{resource_id: resource_id, collection_id: collection_id}, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
      Repo.transact_with(fn ->
        with {:ok, collection} <- Collections.one([:default, id: collection_id, user: user]),
             {:ok, resource} <- resource(%{resource_id: resource_id}, info),
             attrs = Map.take(resource, ~w(name summary icon url license)a) do
          Resources.create(user, collection, attrs)
        end
      end)
    end
  end

  def last_activity_edge(_, _, _info), do: {:ok, DateTime.utc_now()}

end
