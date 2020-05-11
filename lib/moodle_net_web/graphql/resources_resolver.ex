# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ResourcesResolver do
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  alias MoodleNet.{Collections, GraphQL, Repo, Resources, Uploads}
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Collections.Collection
  alias MoodleNet.GraphQL.{FetchFields, ResolveFields}
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Uploads.{IconUploader, ResourceUploader}
  alias MoodleNetWeb.GraphQL.UploadResolver

  def resource(%{resource_id: id}, info) do
    Resources.one(id: id, user: GraphQL.current_user(info))
  end

  def is_local_edge(%{collection: %Collection{actor: %Actor{peer_id: peer_id}}}, _, _) do
    {:ok, is_nil(peer_id)}
  end

  def is_local_edge(%{collection_id: id}, _, info) do
    ResolveFields.run(
      %ResolveFields{
        module: __MODULE__,
        fetcher: :fetch_collection_edge,
        context: id,
        info: info,
        getter_fn: fn _context, _default ->
          fn edges ->
            ret =
              edges
              |> Map.get(id, %{})
              |> Map.get(:actor, %{})
              |> Map.get(:peer_id)
              |> is_nil()
            {:ok, ret}
          end
        end,
      }
    )
  end

  def collection_edge(%Resource{collection: %Collection{}=c}, _, _info), do: {:ok, c}
  def collection_edge(%Resource{collection_id: id}, _, info) do
    ResolveFields.run(
      %ResolveFields{
        module: __MODULE__,
        fetcher: :fetch_collection_edge,
        context: id,
        info: info,
      }
    )
  end

  def fetch_collection_edge(_, ids) do
    FetchFields.run(
      %FetchFields{
        queries: Collections.Queries,
        query: Collection,
        group_fn: &(&1.id),
        filters: [:default, id: ids],
      }
    )
  end

  def create_resource(%{resource: attrs, collection_id: collection_id} = params, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
      Repo.transact_with(fn ->
        with {:ok, uploads} <- UploadResolver.upload(user, params, info),
             {:ok, collection} <- Collections.one([:default, user: user, id: collection_id]),
             attrs = Map.merge(attrs, uploads),
             {:ok, resource} <- Resources.create(user, collection, attrs) do
          {:ok, %{ resource | collection: collection } }
        end
      end)
    end
  end

  def update_resource(%{resource: changes, resource_id: resource_id} = params, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
      Repo.transact_with(fn ->
        with {:ok, resource} <- resource(%{resource_id: resource_id}, info) do
          resource = Repo.preload(resource, [collection: :community])
          permitted? =
            user.local_user.is_instance_admin or
            resource.collection.creator_id ==user.id or
            resource.collection.community.creator_id == user.id

          if permitted? do
            with {:ok, uploads} <- UploadResolver.upload(user, params, info) do
              Resources.update(resource, Map.merge(changes, uploads))
            end
          else
            GraphQL.not_permitted()
          end
        end
      end)
    end
  end

  def copy_resource(%{resource_id: resource_id, collection_id: collection_id}, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
      Repo.transact_with(fn ->
        with {:ok, collection} <- Collections.one([:default, id: collection_id, user: user]),
             {:ok, resource} <- resource(%{resource_id: resource_id}, info),
             attrs = Map.take(resource, ~w(content_id name summary icon url license)a) do
          Resources.create(user, collection, attrs)
        end
      end)
    end
  end

  def last_activity_edge(_, _, _info), do: {:ok, DateTime.utc_now()}
end
