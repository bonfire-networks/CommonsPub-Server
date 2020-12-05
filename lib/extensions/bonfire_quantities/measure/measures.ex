# SPDX-License-Identifier: AGPL-3.0-only
defmodule Bonfire.Quantify.Measures do

  alias CommonsPub.GraphQL.{Fields, Page, Pagination}
  # alias CommonsPub.Contexts

  alias Bonfire.Quantify.{Measure, Unit}
  alias Bonfire.Quantify.Measures.Queries

  @user CommonsPub.Users.User
  @repo CommonsPub.Repo

  def cursor(), do: &[&1.id]
  def test_cursor(), do: &[&1["id"]]

  @doc """
  Retrieves a single collection by arbitrary filters.
  Used by:
  * GraphQL Item queries
  * ActivityPub integration
  * Various parts of the codebase that need to query for collections (inc. tests)
  """
  def one(filters), do: @repo.single(Queries.query(Measure, filters))

  @doc """
  Retrieves a list of collections by arbitrary filters.
  Used by:
  * Various parts of the codebase that need to query for collections (inc. tests)
  """
  def many(filters \\ []), do: {:ok, @repo.all(Queries.query(Measure, filters))}

  def fields(group_fn, filters \\ [])
      when is_function(group_fn, 1) do
    {:ok, fields} = many(filters)
    {:ok, Fields.new(fields, group_fn)}
  end

  @doc """
  Retrieves an Page of units according to various filters

  Used by:
  * GraphQL resolver single-parent resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])

  def page(cursor_fn, %{} = page_opts, base_filters, data_filters, count_filters) do
    base_q = Queries.query(Measure, base_filters)
    data_q = Queries.filter(base_q, data_filters)
    count_q = Queries.filter(base_q, count_filters)

    with {:ok, [data, counts]} <- @repo.transact_many(all: data_q, count: count_q) do
      {:ok, Page.new(data, counts, cursor_fn, page_opts)}
    end
  end

  @doc """
  Retrieves an Pages of units according to various filters

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
    Pagination.pages(
      Queries,
      Measure,
      cursor_fn,
      group_fn,
      page_opts,
      base_filters,
      data_filters,
      count_filters
    )
  end

  ## mutations

  @spec create(@user.t(), Unit.t(), attrs :: map) :: {:ok, Measure.t()} | {:error, Changeset.t()}
  def create(%@user{} = creator, %Unit{} = unit, attrs) when is_map(attrs) do
    @repo.transact_with(fn ->
      with {:ok, item} <- insert_measure(creator, unit, attrs) do
        #  act_attrs = %{verb: "created", is_local: true},
        #  {:ok, activity} <- Activities.create(creator, item, act_attrs), #FIXME
        #  :ok <- publish(creator, community, item, activity, :created),
        # do
        {:ok, %{item | unit: unit}}
      end
    end)
  end

  defp insert_measure(creator, unit, attrs) do
    # TODO: use upsert?
    # TODO: should we re-use the same measurement instead of storing duplicates? (but would have to be careful to insert a new measurement rather than update)
    @repo.insert(Bonfire.Quantify.Measure.create_changeset(creator, unit, attrs)
      # on_conflict: [set: [has_numerical_value: attrs.has_numerical_value]]
    )
  end

  # defp publish(creator, measure, activity, :created) do # TODO
  #   feeds = [
  #     community.outbox_id, CommonsPub.Feeds.outbox_id(creator),
  #     measure.outbox_id, Feeds.instance_outbox_id(),
  #   ]
  #   with :ok <- FeedActivities.publish(activity, feeds) do
  #     ap_publish(measure.id, creator.id)
  #   end
  # end
  # defp publish(measure, :updated) do
  #   ap_publish(measure.id, measure.creator_id) # TODO: wrong if edited by admin
  # end
  # defp publish(measure, :deleted) do
  #   ap_publish(measure.id, measure.creator_id) # TODO: wrong if edited by admin
  # end

  # defp ap_publish(context_id, user_id) do
  #   CommonsPub.FeedPublisher.publish(%{
  #     "context_id" => context_id,
  #     "user_id" => user_id,
  #   })
  # end
  # defp ap_publish(_, _, _), do: :ok

  # TODO: take the user who is performing the update
  @spec update(Measure.t(), attrs :: map) :: {:ok, Measure.t()} | {:error, Changeset.t()}
  def update(%Measure{} = measure, attrs) do
    @repo.transact_with(fn ->
      with {:ok, measure} <- @repo.update(Measure.update_changeset(measure, attrs)) do
        #  :ok <- publish(measure, :updated) do
        {:ok, measure}
      end
    end)
  end

  # def soft_delete(%Measure{} = measure) do
  #   @repo.transact_with(fn ->
  #     with {:ok, measure} <- Common.Deletion.soft_delete(measure),
  #          :ok <- publish(measure, :deleted) do
  #       {:ok, measure}
  #     end
  #   end)
  # end
end
