# SPDX-License-Identifier: AGPL-3.0-only
defmodule Geolocation.Geolocations do
  alias CommonsPub.{
    Activities,
    Common,
    Feeds,
    Follows,
    Repo
  }

  alias CommonsPub.Character.Characters

  alias CommonsPub.GraphQL.{Fields, Page}
  alias CommonsPub.Common.Contexts
  alias Geolocation
  alias Geolocation.Queries
  alias CommonsPub.Feeds.FeedActivities
  alias CommonsPub.Users.User
  alias CommonsPub.Workers.APPublishWorker

  def cursor(:followers), do: &[&1.follower_count, &1.id]
  def test_cursor(:followers), do: &[&1["followerCount"], &1["id"]]

  @doc """
  Retrieves a single collection by arbitrary filters.
  Used by:
  * GraphQL Item queries
  * ActivityPub integration
  * Various parts of the codebase that need to query for collections (inc. tests)
  """
  def one(filters), do: Repo.single(Queries.query(Geolocation, filters))

  @doc """
  Retrieves a list of collections by arbitrary filters.
  Used by:
  * Various parts of the codebase that need to query for collections (inc. tests)
  """
  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Geolocation, filters))}

  def fields(group_fn, filters \\ [])
      when is_function(group_fn, 1) do
    {:ok, fields} = many(filters)
    {:ok, Fields.new(fields, group_fn)}
  end

  @doc """
  Retrieves an Page of geolocations according to various filters

  Used by:
  * GraphQL resolver single-parent resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])

  def page(cursor_fn, %{} = page_opts, base_filters, data_filters, count_filters) do
    base_q = Queries.query(Geolocation, base_filters)
    data_q = Queries.filter(base_q, data_filters)
    count_q = Queries.filter(base_q, count_filters)

    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, Page.new(data, counts, cursor_fn, page_opts)}
    end
  end

  @doc """
  Retrieves an Pages of geolocations according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def pages(
        cursor_fn,
        group_fn,
        page_opts,
        base_filters \\ [],
        data_filters \\ [],
        count_filters \\ []
      )

  def pages(cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters) do
    Contexts.pages(
      Queries,
      Geolocation,
      cursor_fn,
      group_fn,
      page_opts,
      base_filters,
      data_filters,
      count_filters
    )
  end

  ## mutations

  @spec create(User.t(), context :: any, attrs :: map) ::
          {:ok, Geolocation.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, context, attrs) when is_map(attrs) do
    attrs = Map.put(attrs, :preferred_username, Characters.atomise_username(attrs[:name]))

    Repo.transact_with(fn ->
      with {:ok, actor} <- Characters.create(attrs),
           {:ok, attrs} <- resolve_mappable_address(attrs),
           {:ok, item_attrs} <- create_boxes(actor, attrs),
           {:ok, item} <- insert_geolocation(creator, context, actor, item_attrs),
           act_attrs = %{verb: "created", is_local: true},
           {:ok, activity} <- Activities.create(creator, item, act_attrs),
           :ok <- publish(creator, context, item, activity, :created),
           {:ok, _follow} <- Follows.create(creator, item, %{is_local: true}) do
        {:ok, populate_coordinates(item)}
      end
    end)
  end

  @spec create(User.t(), attrs :: map) :: {:ok, Geolocation.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, attrs) when is_map(attrs) do
    attrs = Map.put(attrs, :preferred_username, Characters.atomise_username(attrs[:name]))

    Repo.transact_with(fn ->
      with {:ok, actor} <- Characters.create(attrs),
           {:ok, attrs} <- resolve_mappable_address(attrs),
           {:ok, item_attrs} <- create_boxes(actor, attrs),
           {:ok, item} <- insert_geolocation(creator, actor, item_attrs),
           act_attrs = %{verb: "created", is_local: true},
           {:ok, activity} <- Activities.create(creator, item, act_attrs),
           :ok <- publish(creator, item, activity, :created),
           {:ok, _follow} <- Follows.create(creator, item, %{is_local: true}) do
        {:ok, populate_coordinates(item)}
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

  defp insert_geolocation(creator, context, actor, attrs) do
    cs = Geolocation.create_changeset(creator, context, actor, attrs)

    with {:ok, item} <- Repo.insert(cs) do
      {:ok, %{item | actor: actor, context: context}}
    end
  end

  defp insert_geolocation(creator, actor, attrs) do
    cs = Geolocation.create_changeset(creator, actor, attrs)
    with {:ok, item} <- Repo.insert(cs), do: {:ok, %{item | actor: actor}}
  end

  defp publish(creator, context, geolocation, activity, :created) do
    feeds = [
      context.outbox_id,
      creator.outbox_id,
      geolocation.outbox_id,
      Feeds.instance_outbox_id()
    ]

    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish("create", geolocation.id, creator.id)
    end
  end

  defp publish(creator, geolocation, activity, :created) do
    feeds = [
      creator.outbox_id,
      geolocation.outbox_id,
      Feeds.instance_outbox_id()
    ]

    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish("create", geolocation.id, creator.id)
    end
  end

  defp ap_publish(verb, context_id, user_id) do
    job_result =
      APPublishWorker.enqueue(verb, %{
        "context_id" => context_id,
        "user_id" => user_id
      })

    with {:ok, _} <- job_result, do: :ok
  end

  defp ap_publish(_, _, _), do: :ok

  @spec update(User.t(), Geolocation.t(), attrs :: map) ::
          {:ok, Geolocation.t()} | {:error, Changeset.t()}
  def update(%User{} = user, %Geolocation{} = geolocation, attrs) do
    with {:ok, attrs} <- resolve_mappable_address(attrs),
         {:ok, item} <- Repo.update(Geolocation.update_changeset(geolocation, attrs)),
         :ok <- ap_publish("update", item.id, user.id) do
      {:ok, populate_coordinates(item)}
    end
  end

  @spec soft_delete(User.t(), Geolocation.t()) :: {:ok, Geolocation.t()} | {:error, Changeset.t()}
  def soft_delete(%User{} = user, %Geolocation{} = geo) do
    Repo.transact_with(fn ->
      with {:ok, geo} <- Common.soft_delete(geo),
           :ok <- ap_publish("delete", geo.id, user.id) do
        {:ok, geo}
      end
    end)
  end

  def populate_coordinates(%Geolocation{geom: geom} = geo) when not is_nil(geom) do
    {lat, long} = geo.geom.coordinates

    %{geo | lat: lat, long: long, geom: Geo.JSON.encode!(geom)}
  end

  def populate_coordinates(geo), do: geo || %{}

  def resolve_mappable_address(%{mappable_address: address} = attrs) when is_binary(address) do
    with {:ok, coords} <- Geocoder.call(address) do
      # IO.inspect(attrs)
      # IO.inspect(coords)
      # TODO: should take bounds and save in `geom`
      {:ok, Map.put(Map.put(attrs, :lat, coords.lat), :long, coords.lon)}
    else
      _ -> {:ok, attrs}
    end
  end

  def resolve_mappable_address(attrs), do: {:ok, attrs}
end
