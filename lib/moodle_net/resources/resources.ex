# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Resources do
  alias Ecto.Changeset
  alias Ecto.Association.NotLoaded
  alias MoodleNet.{Activities, Common, Collections, Feeds, Repo}
  alias MoodleNet.Batching.{Edges, EdgesPage, EdgesPages, NodesPage}
  alias MoodleNet.Collections.Collection
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

  def edges(group_fn, filters \\ [], page_opts \\ %{})
  when is_function(group_fn, 1) do
    {:ok, edges} = many(filters)
    {:ok, Edges.new(edges, group_fn, page_opts)}
  end

  @doc """
  Retrieves an EdgesPage of communities according to various filters

  Used by:
  * GraphQL resolver single-parent resolution
  """
  def edges_page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def edges_page(cursor_fn, %{}=page_opts, base_filters, data_filters, count_filters)
  when is_function(cursor_fn, 1) do
    {data_q, count_q} = Queries.queries(Resource, base_filters, data_filters, count_filters)
    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, EdgesPage.new(data, counts, cursor_fn, page_opts)}
    end
  end

  @doc """
  Retrieves an EdgesPages of communities according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def edges_pages(cursor_fn, group_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def edges_pages(cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters)
  when is_function(cursor_fn, 1) and is_function(group_fn, 1) do
    {data_q, count_q} = Queries.queries(Resource, base_filters, data_filters, count_filters)
    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, all: count_q) do
      {:ok, EdgesPages.new(data, counts, cursor_fn, group_fn, page_opts)}
    end
  end

  ## and now the writes...

  @spec create(User.t(), Collection.t(), attrs :: map) ::
          {:ok, Resource.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %Collection{} = collection, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      with {:ok, resource} <- insert_resource(creator, collection, attrs),
           act_attrs = %{verb: "created", is_local: is_local(resource)},
           {:ok, activity} <- insert_activity(creator, resource, act_attrs),
           :ok <- publish(creator, collection, resource, activity, :created) do
        {:ok, %Resource{resource | creator: creator}}
      end
    end)
  end

  defp insert_activity(creator, resource, attrs) do
    Activities.create(creator, resource, attrs)
  end

  # TODO
  defp publish(_creator, collection, resource, activity, :created) do
    community = Repo.preload(collection, :community).community
    feeds = [collection.outbox_id, community.outbox_id, Feeds.instance_outbox_id()]
    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish(resource.id, resource.creator_id, is_local(resource))
    end
  end
  defp publish(resource, :updated) do
    ap_publish(resource.id, resource.creator_id, is_local(resource))
  end
  defp publish(resource, :deleted) do
    ap_publish(resource.id, resource.creator_id, is_local(resource))
  end

  defp ap_publish(context_id, user_id, true) do
    MoodleNet.FeedPublisher.publish(%{
      "context_id" => context_id,
      "user_id" => user_id,
    })
  end
  defp ap_publish(_, _, _), do: :ok

  defp insert_resource(creator, collection, attrs) do
    Repo.insert(Resource.create_changeset(creator, collection, attrs))
  end

  @spec update(Resource.t(), attrs :: map) :: {:ok, Resource.t()} | {:error, Changeset.t()}
  def update(%Resource{} = resource, attrs) when is_map(attrs) do
    if is_local(resource) do
      with {:ok, updated} <- Repo.update(Resource.update_changeset(resource, attrs)),
           :ok <- publish(resource, :updated) do
        {:ok, updated}
      end
    else
      Repo.update(Resource.update_changeset(resource, attrs))
    end
  end

  @spec soft_delete(Resource.t()) :: {:ok, Resource.t()} | {:error, Changeset.t()}
  def soft_delete(%Resource{} = resource) do
    if is_local(resource) do
      with {:ok, deleted} <- Common.soft_delete(resource),
           :ok <- publish(deleted, :deleted) do
        {:ok, deleted}
      end
    else
      Common.soft_delete(resource)
    end
  end

  @spec is_local(Resource.t()) :: boolean
  def is_local(%{collection_id: id} = resource) when is_binary(id) do
    case Collections.one([:default, id: resource.collection_id]) do
      {:ok, collection} -> is_nil(collection.actor.peer_id)
      # shouldn't happen
      _ -> false
    end
  end
end
