# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Resources do
  alias Ecto.Changeset
  alias Ecto.Association.NotLoaded
  alias MoodleNet.{Activities, Common, Collections, Feeds, Repo}
  alias MoodleNet.Common.Contexts
  alias MoodleNet.GraphQL.Fields
  alias MoodleNet.Collections.Collection
  alias MoodleNet.FeedPublisher
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.Resources.{Resource, Queries}
  alias MoodleNet.Users.User

  @doc """
  Retrieves a single resource by arbitrary filters.
  Used by:
  * GraphQL Item queries
  * ActivityPub integration
  * Various parts of the codebase that need to query for resources (inc. tests)
  """
  def one(filters), do: Repo.single(Queries.query(Resource, filters))

  @doc """
  Retrieves a list of resources by arbitrary filters.
  Used by:
  * Various parts of the codebase that need to query for resources (inc. tests)
  """
  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Resource, filters))}

  ## and now the writes...

  @spec create(User.t(), Collection.t(), attrs :: map) ::
          {:ok, Resource.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %Collection{} = collection, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      with {:ok, resource} <- insert_resource(creator, collection, attrs),
           act_attrs = %{verb: "created", is_local: is_nil(collection.actor.peer_id)},
           {:ok, activity} <- insert_activity(creator, resource, act_attrs),
           :ok <- publish(creator, collection, resource, activity, :created),
           :ok <- ap_publish(creator, resource) do
        {:ok, %Resource{resource | creator: creator}}
      end
    end)
  end


  defp insert_activity(creator, resource, attrs) do
    Activities.create(creator, resource, attrs)
  end

  defp publish(_creator, collection, resource, activity, :created) do
    community = Repo.preload(collection, :community).community
    feeds = [collection.outbox_id, community.outbox_id, Feeds.instance_outbox_id()]
    FeedActivities.publish(activity, feeds)
  end
  defp publish(resource, :updated), do: :ok
  defp publish(resource, :deleted), do: :ok

  defp ap_publish(%{creator_id: id} = resource), do: ap_publish(%{id: id}, resource)

  defp ap_publish(user, %{collection: %{actor: %{peer_id: nil}}}=resource) do
    FeedPublisher.publish(%{"context_id" => resource.id, "user_id" => user.id})
  end
  defp ap_publish(_, _), do: :ok

  defp insert_resource(creator, collection, attrs) do
    Repo.insert(Resource.create_changeset(creator, collection, attrs))
  end

  @spec update(Resource.t(), attrs :: map) :: {:ok, Resource.t()} | {:error, Changeset.t()}
  def update(%Resource{} = resource, attrs) when is_map(attrs) do
    with {:ok, updated} <- Repo.update(Resource.update_changeset(resource, attrs)),
         :ok <- publish(resource, :updated),
         :ok <- ap_publish(resource) do
      {:ok, updated}
    end
  end

  @spec soft_delete(Resource.t()) :: {:ok, Resource.t()} | {:error, Changeset.t()}
  def soft_delete(%Resource{} = resource) do
    resource = Repo.preload(resource, [collection: [:actor]])
    with {:ok, deleted} <- Common.soft_delete(resource),
         :ok <- publish(deleted, :deleted),
         :ok <- ap_publish(resource) do
      {:ok, deleted}
    end
  end

  ### behaviour callbacks

  def context_module, do: Users

  def queries_module, do: Users.Queries

  def follow_filters, do: []

end
