# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Geolocations do
  alias MoodleNet.{Activities, Actors, Common, Feeds, Follows, Repo}
  alias MoodleNet.GraphQL.{Fields, Page}
  alias MoodleNet.Common.Contexts
  alias MoodleNet.Geolocation
  alias MoodleNet.Geolocations.Queries
  # alias MoodleNet.Users.User


  @doc """
  Retrieves a single Geolocation by arbitrary filters.
  Used by:
  * GraphQL Item queries
  * ActivityPub integration
  * Various parts of the codebase that need to query for Geolocations (inc. tests)
  """
  def one(filters), do: Repo.single(Queries.query(Geolocation, filters))

  @doc """
  Retrieves a list of Geolocations by arbitrary filters.
  Used by:
  * Various parts of the codebase that need to query for Geolocations (inc. tests)
  """
  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Geolocation, filters))}

  def fields(group_fn, filters \\ [])
  when is_function(group_fn, 1) do
    {:ok, fields} = many(filters)
    {:ok, Fields.new(fields, group_fn)}
  end

  @doc """
  Retrieves an Page of Geolocations according to various filters

  Used by:
  * GraphQL resolver single-parent resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def page(cursor_fn, %{}=page_opts, base_filters, data_filters, count_filters) do
    base_q = Queries.query(Geolocation, base_filters)
    data_q = Queries.filter(base_q, data_filters)
    count_q = Queries.filter(base_q, count_filters)
    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, Page.new(data, counts, cursor_fn, page_opts)}
    end
  end

  @doc """
  Retrieves an Pages of Geolocations according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def pages(cursor_fn, group_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def pages(cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters) do
    Contexts.pages Queries, Geolocation,
      cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters
  end

  ## mutations


  @spec create(User.t(), Community.t(), attrs :: map) :: {:ok, Geolocation.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %Community{} = community, attrs) when is_map(attrs) do
    # attrs = Map.put(attrs, :preferred_username, preferred_username)

    Repo.transact_with(fn ->
      with {:ok, actor} <- Actors.create(attrs),
           {:ok, coll_attrs} <- create_boxes(actor, attrs),
           {:ok, coll} <- insert_geolocation(creator, community, actor, coll_attrs),
           act_attrs = %{verb: "created", is_local: true},
           {:ok, activity} <- Activities.create(creator, coll, act_attrs),
           :ok <- publish(creator, community, coll, activity, :created),
           {:ok, _follow} <- Follows.create(creator, coll, %{is_local: true}) do
        {:ok, coll}
      end
    end)
  end

  defp create_boxes(%{peer_id: nil}, attrs), do: create_local_boxes(attrs)
  defp create_boxes(%{peer_id: _}, attrs), do: create_remote_boxes(attrs)

  defp create_local_boxes(attrs) do
    with {:ok, inbox} <- Feeds.create(),
         {:ok, outbox} <- Feeds.create() do
      extra = %{inbox_id: inbox.id, outbox_id: outbox.id}
      {:ok, Map.merge(attrs, extra)}
    end
  end

  defp create_remote_boxes(attrs) do
    with {:ok, outbox} <- Feeds.create() do
      {:ok, Map.put(attrs, :outbox_id, outbox.id)}
    end
  end

  defp insert_geolocation(creator, community, actor, attrs) do
    cs = Geolocation.create_changeset(creator, community, actor, attrs)
    with {:ok, coll} <- Repo.insert(cs), do: {:ok, %{ coll | actor: actor }}
  end


  # TODO: take the user who is performing the update
  @spec update(%Geolocation{}, attrs :: map) :: {:ok, Geolocation.t()} | {:error, Changeset.t()}
  def update(%Geolocation{} = Geolocation, attrs) do
    Repo.transact_with(fn ->
      Geolocation = Repo.preload(Geolocation, :community)
      with {:ok, Geolocation} <- Repo.update(Geolocation.update_changeset(Geolocation, attrs)),
           {:ok, actor} <- Actors.update(Geolocation.actor, attrs),
           :ok <- publish(Geolocation, :updated) do
        {:ok, %{ Geolocation | actor: actor }}
      end
    end)
  end

  def soft_delete(%Geolocation{} = Geolocation) do
    Repo.transact_with(fn ->
      with {:ok, Geolocation} <- Common.soft_delete(Geolocation),
           :ok <- publish(Geolocation, :deleted) do
        {:ok, Geolocation}
      end
    end)
  end

end
