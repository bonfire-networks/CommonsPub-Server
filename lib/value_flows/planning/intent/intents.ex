# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Planning.Intent.Intents do
  alias MoodleNet.{Activities, Actors, Common, Feeds, Follows, Repo}
  alias MoodleNet.GraphQL.{Fields, Page}
  alias MoodleNet.Common.Contexts
  alias MoodleNet.Communities.Community
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.Users.User

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


  @spec create(User.t(), Community.t(), attrs :: map) :: {:ok, Intent.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %Community{} = community, attrs) when is_map(attrs) do

    Repo.transact_with(fn ->
      with {:ok, item} <- insert_unit(creator, community, attrs),
           act_attrs = %{verb: "created", is_local: true},
           {:ok, activity} <- Activities.create(creator, item, act_attrs), #FIXME
           :ok <- publish(creator, community, item, activity, :created)
          do
            {:ok, item}
          end
    end)
  end

  @spec create(User.t(), attrs :: map) :: {:ok, Intent.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, attrs) when is_map(attrs) do

    IO.inspect(attrs)

    Repo.transact_with(fn ->
      with {:ok, item} <- insert_unit(creator, attrs),
           act_attrs = %{verb: "created", is_local: true},
           {:ok, activity} <- Activities.create(creator, item, act_attrs), #FIXME
           :ok <- publish(creator, item, activity, :created)
          do
            {:ok, item}
          end
    end)
  end

  defp insert_unit(creator, attrs) do
    cs = ValueFlows.Planning.Intent.create_changeset(creator, attrs)
    with {:ok, item} <- Repo.insert(cs), do: {:ok, item }
  end

  defp insert_unit(creator, community, attrs) do
    cs = ValueFlows.Planning.Intent.create_changeset(creator, community, attrs)
    with {:ok, item} <- Repo.insert(cs), do: {:ok, item }
  end

  defp publish(creator, intent, activity, :created) do
    feeds = [
      creator.outbox_id,
      Feeds.instance_outbox_id(),
    ]
    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish(intent.id, creator.id)
    end
  end
  defp publish(creator, community, intent, activity, :created) do
    feeds = [
      community.outbox_id, creator.outbox_id,
      Feeds.instance_outbox_id(),
    ]
    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish(intent.id, creator.id)
    end
  end
  defp publish(intent, :updated) do
    ap_publish(intent.id, intent.creator_id) # TODO: wrong if edited by admin
  end
  defp publish(intent, :deleted) do
    ap_publish(intent.id, intent.creator_id) # TODO: wrong if edited by admin
  end

  defp ap_publish(context_id, user_id) do
    MoodleNet.FeedPublisher.publish(%{
      "context_id" => context_id,
      "user_id" => user_id,
    })
  end
  defp ap_publish(_, _, _), do: :ok

  # TODO: take the user who is performing the update
  @spec update(%Intent{}, attrs :: map) :: {:ok, ValueFlows.Planning.Intent.t()} | {:error, Changeset.t()}
  def update(%Intent{} = intent, attrs) do
    Repo.transact_with(fn ->
      intent = Repo.preload(intent, :community)
      IO.inspect(intent)

      with {:ok, intent} <- Repo.update(ValueFlows.Planning.Intent.update_changeset(intent, attrs)) do
          #  :ok <- publish(intent, :updated) do
          #   IO.inspect("intent")
          #   IO.inspect(intent)
            {:ok,  intent }
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

end
