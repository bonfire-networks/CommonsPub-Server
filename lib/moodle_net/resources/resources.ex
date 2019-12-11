# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Resources do
  import Ecto.Query

  alias Ecto.Changeset
  alias MoodleNet.{Activities, Common, Repo, Meta, Users}
  alias MoodleNet.Common.{Query, NotFoundError}
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Users.User
  alias Ecto.Association.NotLoaded

  @spec list() :: [Resource.t()]
  def list, do: Repo.all(list_q())

  defp list_q do
    Resource
    |> Query.only_public()
    |> Query.only_undeleted()
    |> Query.order_by_recently_updated()
    |> only_from_undeleted_collections()
  end

  defp only_from_undeleted_collections(query) do
    from(q in query,
      join: c in assoc(q, :collection),
      on: q.collection_id == c.id,
      where: not is_nil(c.published_at),
      where: is_nil(c.deleted_at)
    )
  end

  @spec list_in_collection(Collection.t()) :: [Resource.t()]
  def list_in_collection(%Collection{id: id}), do: Repo.all(list_in_collection_q(id))

  defp list_in_collection_q(id) do
    from(res in Resource,
      join: coll in Collection,
      on: res.collection_id == coll.id,
      where: coll.id == ^id,
      where: not is_nil(coll.published_at),
      where: is_nil(coll.deleted_at)
    )
  end

  @spec count_for_list_in_collection(Collection.t()) :: [Resource.t()]
  def count_for_list_in_collection(%Collection{id: id}),
    do: Repo.one(count_for_list_in_collection_q(id))

  defp count_for_list_in_collection_q(id) do
    from(res in Resource,
      join: coll in Collection,
      on: res.collection_id == coll.id,
      where: coll.id == ^id,
      where: not is_nil(coll.published_at),
      where: is_nil(coll.deleted_at),
      select: count(res)
    )
  end

  @spec fetch(binary()) :: {:ok, Resource.t()} | {:error, NotFoundError.t()}
  def fetch(id) do
    with {:ok, {resource, peer_id}} <- Repo.single(fetch_q(id)) do
      {:ok, Map.put(resource, :is_local, is_nil(peer_id))}
    end
  end

  def fetch_q(id) do
    from r in Resource,
      join: c in assoc(r, :collection),
      join: a in assoc(c, :actor),
      where: r.id == ^id,
      where: not is_nil(r.published_at),
      where: not is_nil(c.published_at),
      where: is_nil(r.deleted_at),
      where: is_nil(c.deleted_at),
      select: {r, a.peer_id}
  end

  @spec fetch_creator(Resource.t()) :: {:ok, User.t()} | {:error, NotFoundError.t()}
  def fetch_creator(%Resource{creator_id: id, creator: %NotLoaded{}}), do: Users.fetch(id)
  def fetch_creator(%Resource{creator: creator}), do: {:ok, creator}

  @spec create(User.t(), Collection.t(), attrs :: map) ::
          {:ok, Resource.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %Collection{} = collection, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      res_attrs = Map.put(attrs, :is_local, is_nil(collection.actor.peer_id))
      with {:ok, resource} <- insert_resource(creator, collection, res_attrs),
           act_attrs = %{verb: "create", is_local: resource.is_local},
           {:ok, activity} <- insert_activity(creator, resource, act_attrs),
           :ok <- publish(creator, collection, resource, activity, :create) do
        {:ok, %Resource{resource | creator: creator}}
      end
    end)
  end

  defp insert_activity(creator, resource, attrs) do
    Activities.create(creator, resource, attrs)
  end

  # TODO
  defp publish(creator, collection, resource, activity, :create) do
    case resource.is_local do
      true -> :ok
      false -> :ok # activitypub?
    end
    # MoodleNet.FeedPublisher.publish(%{
    #   "verb" => verb,
    #   "context_id" => resource.id,
    #   "user_id" => resource.creator_id,
    # })
  end
  defp publish(creator, collection, resource, activity, _verb) do
    :ok # activitypub?
  end

  defp insert_resource(creator, collection, attrs) do
    Repo.insert(Resource.create_changeset(creator, collection, attrs))
  end

  @spec update(Resource.t(), attrs :: map) :: {:ok, Resource.t()} | {:error, Changeset.t()}
  def update(%Resource{} = resource, attrs) when is_map(attrs) do
    Repo.update(Resource.update_changeset(resource, attrs))
  end

  @spec soft_delete(Resource.t()) :: {:ok, Resource.t()} | {:error, Changeset.t()}
  def soft_delete(%Resource{} = resource), do: Common.soft_delete(resource)

end
