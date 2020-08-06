# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Planning.Intent.Intents do
  alias MoodleNet.{Activities, Actors, Common, Feeds, Follows, Repo}
  alias MoodleNet.GraphQL.{Fields, Page}
  alias MoodleNet.Common.Contexts
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.Users.User

  alias Geolocation.Geolocations
  alias Measurement.Measure
  alias ValueFlows.Planning.Intent
  alias ValueFlows.Planning.Intent.Queries
  alias ValueFlows.Knowledge.Action
  alias ValueFlows.Knowledge.Action.Actions

  def cursor(), do: &[&1.id]
  def test_cursor(), do: &[&1["id"]]

  @doc """
  Retrieves a single one by arbitrary filters.
  Used by:
  * GraphQL Item queries
  * ActivityPub integration
  * Various parts of the codebase that need to query for collections (inc. tests)
  """
  def one(filters), do: Repo.single(Queries.query(Intent, filters))

  @doc """
  Retrieves a list of them by arbitrary filters.
  Used by:
  * Various parts of the codebase that need to query for collections (inc. tests)
  """
  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Intent, filters))}

  def fields(group_fn, filters \\ [])
      when is_function(group_fn, 1) do
    {:ok, fields} = many(filters)
    {:ok, Fields.new(fields, group_fn)}
  end

  @doc """
  Retrieves an Page of intents according to various filters

  Used by:
  * GraphQL resolver single-parent resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])

  def page(cursor_fn, %{} = page_opts, base_filters, data_filters, count_filters) do
    base_q = Queries.query(Intent, base_filters)
    data_q = Queries.filter(base_q, data_filters)
    count_q = Queries.filter(base_q, count_filters)

    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, Page.new(data, counts, cursor_fn, page_opts)}
    end
  end

  @doc """
  Retrieves an Pages of intents according to various filters

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
      Intent,
      cursor_fn,
      group_fn,
      page_opts,
      base_filters,
      data_filters,
      count_filters
    )
  end

  ## mutations

  # @spec create(User.t(), Community.t(), attrs :: map) :: {:ok, Intent.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %Action{} = action, %{id: _id} = context, attrs) when is_map(attrs) do
    do_create(creator, attrs, fn ->
      Intent.create_changeset(creator, action, context, attrs)
    end)
  end

  # @spec create(User.t(), attrs :: map) :: {:ok, Intent.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %Action{} = action, attrs) when is_map(attrs) do
    do_create(creator, attrs, fn ->
      Intent.create_changeset(creator, action, attrs)
    end)
  end

  def do_create(creator, attrs, changeset_fn) do
    attrs = parse_measurement_attrs(attrs)

    Repo.transact_with(fn ->
      cs =
        changeset_fn.()
        |> Intent.change_measures(attrs)

      with {:ok, cs} <- change_at_location(cs, attrs),
           {:ok, item} <- Repo.insert(cs),
           {:ok, item} <- ValueFlows.Util.try_tag_thing(creator, item, attrs),
           act_attrs = %{verb: "created", is_local: true},
           # FIXME
           {:ok, activity} <- Activities.create(creator, item, act_attrs),
           :ok <- index(item),
           :ok <- publish(creator, item, activity, :created) do
        {:ok, item}
      end
    end)
  end

  defp publish(creator, intent, activity, :created) do
    feeds = [
      creator.outbox_id,
      Feeds.instance_outbox_id()
    ]

    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish("create", intent.id, creator.id)
    end
  end

  defp publish(creator, context, intent, activity, :created) do
    feeds = [
      context.outbox_id,
      creator.outbox_id,
      Feeds.instance_outbox_id()
    ]

    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish("create", intent.id, creator.id)
    end
  end

  defp publish(intent, :updated) do
    # TODO: wrong if edited by admin
    ap_publish("update", intent.id, intent.creator_id)
  end

  defp publish(intent, :deleted) do
    # TODO: wrong if edited by admin
    ap_publish("delete", intent.id, intent.creator_id)
  end

  # FIXME
  defp ap_publish(verb, context_id, user_id) do
    MoodleNet.Workers.APPublishWorker.enqueue(verb, %{
      "context_id" => context_id,
      "user_id" => user_id
    })

    :ok
  end

  defp ap_publish(_, _, _), do: :ok

  # TODO: take the user who is performing the update
  # @spec update(%Intent{}, attrs :: map) :: {:ok, Intent.t()} | {:error, Changeset.t()}
  def update(%Intent{} = intent, attrs) do
    do_update(intent, attrs, &Intent.update_changeset(&1, attrs))
  end

  def update(%Intent{} = intent, %{id: id} = context, attrs) do
    do_update(intent, attrs, &Intent.update_changeset(&1, context, attrs))
  end

  def do_update(intent, attrs, changeset_fn) do
    attrs = parse_measurement_attrs(attrs)

    Repo.transact_with(fn ->
      intent =
        Repo.preload(intent, [
          :available_quantity,
          :resource_quantity,
          :effort_quantity,
          :at_location
        ])

      cs =
        intent
        |> changeset_fn.()
        |> Intent.change_measures(attrs)

      with {:ok, cs} <- change_at_location(cs, attrs),
           {:ok, cs} <- change_action(cs, attrs),
           {:ok, intent} <- Repo.update(cs),
           {:ok, intent} <- ValueFlows.Util.try_tag_thing(nil, intent, attrs),
           :ok <- publish(intent, :updated) do
        {:ok, intent}
      end
    end)
  end

  def soft_delete(%Intent{} = intent) do
    Repo.transact_with(fn ->
      with {:ok, intent} <- Common.soft_delete(intent),
           :ok <- publish(intent, :deleted) do
        {:ok, intent}
      end
    end)
  end

  defp index(obj) do
    # icon = MoodleNet.Uploads.remote_url_from_id(obj.icon_id)
    image = MoodleNet.Uploads.remote_url_from_id(obj.image_id)

    object = %{
      "index_type" => "Intent",
      "id" => obj.id,
      # "canonicalUrl" => obj.actor.canonical_url,
      # "icon" => icon,
      "image" => image,
      "name" => obj.name,
      "summary" => Map.get(obj, :note),
      "createdAt" => obj.published_at
      # "index_instance" => URI.parse(obj.actor.canonical_url).host, # home instance of object
    }

    Search.Indexing.maybe_index_object(object)

    :ok
  end

  defp change_action(changeset, %{action: action_id}) do
    with {:ok, action} <- Actions.action(action_id) do
      {:ok, Intent.change_action(changeset, action)}
    end
  end

  defp change_action(changeset, _attrs), do: {:ok, changeset}

  defp change_at_location(changeset, %{at_location: id}) do
    with {:ok, location} <- Geolocations.one([:default, id: id]) do
      {:ok, Intent.change_at_location(changeset, location)}
    end
  end

  defp change_at_location(changeset, _attrs), do: {:ok, changeset}

  defp parse_measurement_attrs(attrs) do
    Enum.reduce(attrs, %{}, fn {k, v}, acc ->
      if is_map(v) and Map.has_key?(v, :has_unit) do
        v = ValueFlows.Util.map_key_replace(v, :has_unit, :unit_id)
        # I have no idea why the numerical value isn't auto converted
        Map.put(acc, k, v)
      else
        Map.put(acc, k, v)
      end
    end)
  end
end
