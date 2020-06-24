# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Planning.Intent.Intents do
  alias MoodleNet.{Activities, Actors, Common, Feeds, Follows, Repo}
  alias MoodleNet.GraphQL.{Fields, Page}
  alias MoodleNet.Common.Contexts
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.Users.User

  alias Measurement.Measure
  alias ValueFlows.Planning.Intent
  alias ValueFlows.Planning.Intent.Queries

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
  def page(cursor_fn, %{}=page_opts, base_filters, data_filters, count_filters) do
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
  def pages(cursor_fn, group_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def pages(cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters) do
    Contexts.pages Queries, Intent,
      cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters
  end

  ## mutations


  # @spec create(User.t(), Community.t(), attrs :: map) :: {:ok, Intent.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %{id: _id} = context, measures, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      with {:ok, item} <- insert_intent(creator, context, measures, attrs),
           act_attrs = %{verb: "created", is_local: true},
           {:ok, activity} <- Activities.create(creator, item, act_attrs), #FIXME
           :ok <- index(item),
           :ok <- publish(creator, context, item, activity, :created)
          do
            {:ok, item}
          end
    end)
  end

  # @spec create(User.t(), attrs :: map) :: {:ok, Intent.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, measures, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      with {:ok, item} <- insert_intent(creator, measures, attrs),
           act_attrs = %{verb: "created", is_local: true},
           {:ok, activity} <- Activities.create(creator, item, act_attrs), #FIXME
           :ok <- index(item),
           :ok <- publish(creator, item, activity, :created)
          do
            {:ok, item}
          end
    end)
  end

  defp insert_intent(creator, measures, attrs) do
    Intent.create_changeset(creator, attrs)
    |> Intent.change_measures(measures)
    |> Repo.insert()
  end

  defp insert_intent(creator, context, measures, attrs) do
    Intent.create_changeset(creator, context, attrs)
    |> Intent.change_measures(measures)
    |> Repo.insert()
  end

  defp publish(creator, intent, activity, :created) do
    feeds = [
      creator.outbox_id,
      Feeds.instance_outbox_id(),
    ]
    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish("create", intent.id, creator.id)
    end
  end
  defp publish(creator, context, intent, activity, :created) do
    feeds = [
      context.outbox_id, creator.outbox_id,
      Feeds.instance_outbox_id(),
    ]
    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish("create", intent.id, creator.id)
    end
  end
  defp publish(intent, :updated) do
    ap_publish("update", intent.id, intent.creator_id) # TODO: wrong if edited by admin
  end
  defp publish(intent, :deleted) do
    ap_publish("delete", intent.id, intent.creator_id) # TODO: wrong if edited by admin
  end

  defp ap_publish(verb, context_id, user_id) do #FIXME
    MoodleNet.Workers.APPublishWorker.enqueue(verb, %{
      "context_id" => context_id,
      "user_id" => user_id,
    })
    :ok
  end
  defp ap_publish(_, _, _), do: :ok

  # TODO: take the user who is performing the update
  # @spec update(%Intent{}, attrs :: map) :: {:ok, Intent.t()} | {:error, Changeset.t()}
  def update(%Intent{} = intent, measures, attrs) when is_map(measures) do
    do_update(intent, measures, &Intent.update_changeset(&1, attrs))
  end

  def update(%Intent{} = intent, %{id: id} = context, measures, attrs) when is_map(measures) do
    do_update(intent, measures, &Intent.update_changeset(&1, context, attrs))
  end

  def do_update(intent, measures, changeset_fn) do
    Repo.transact_with(fn ->
      intent = Repo.preload(intent, [
        :available_quantity, :resource_quantity, :effort_quantity
      ])

      cs = intent
      |> changeset_fn.()
      |> Intent.change_measures(measures)

      with {:ok, intent} <- Repo.update(cs) do
        #  :ok <- publish(intent, :updated) do
        #   IO.inspect("intent")
        #   IO.inspect(intent)
        {:ok, intent}
      end
    end)
  end

  # def soft_delete(%Intent{} = intent) do
  #   Repo.transact_with(fn ->
  #     with {:ok, intent} <- Common.soft_delete(intent),
  #          :ok <- publish(intent, :deleted) do
  #       {:ok, intent}
  #     end
  #   end)
  # end

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
      "createdAt" => obj.published_at,
      # "index_instance" => URI.parse(obj.actor.canonical_url).host, # home instance of object
    }

    Search.Indexing.maybe_index_object(object)

    :ok

  end

end
