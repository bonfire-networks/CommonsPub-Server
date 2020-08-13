# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Proposals do
  alias MoodleNet.{Activities, Actors, Common, Feeds, Follows, Repo}
  alias MoodleNet.GraphQL.{Fields, Page}
  alias MoodleNet.Common.Contexts
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.Users.User
  alias MoodleNet.Meta.Pointers

  alias Geolocation.Geolocations
  alias Measurement.Measure
  alias ValueFlows.Proposal
  alias ValueFlows.Proposal

  alias ValueFlows.Proposal.Queries

  def cursor(), do: &[&1.id]
  def test_cursor(), do: &[&1["id"]]

  @doc """
  Retrieves a single one by arbitrary filters.
  Used by:
  * GraphQL Item queries
  * ActivityPub integration
  * Various parts of the codebase that need to query for collections (inc. tests)
  """
  def one(filters), do: Repo.single(Queries.query(Proposal, filters))

  @doc """
  Retrieves a list of them by arbitrary filters.
  Used by:
  * Various parts of the codebase that need to query for collections (inc. tests)
  """
  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Proposal, filters))}

  def fields(group_fn, filters \\ [])
      when is_function(group_fn, 1) do
    {:ok, fields} = many(filters)
    {:ok, Fields.new(fields, group_fn)}
  end

  @doc """
  Retrieves an Page of proposals according to various filters

  Used by:
  * GraphQL resolver single-parent resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])

  def page(cursor_fn, %{} = page_opts, base_filters, data_filters, count_filters) do
    base_q = Queries.query(Proposal, base_filters)
    data_q = Queries.filter(base_q, data_filters)
    count_q = Queries.filter(base_q, count_filters)

    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, Page.new(data, counts, cursor_fn, page_opts)}
    end
  end

  @doc """
  Retrieves an Pages of proposals according to various filters

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
      Proposal,
      cursor_fn,
      group_fn,
      page_opts,
      base_filters,
      data_filters,
      count_filters
    )
  end

  ## mutations

  # @spec create(User.t(), Community.t(), attrs :: map) :: {:ok, Proposal.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %{id: _id} = context, attrs)
      when is_map(attrs) do
    do_create(creator, attrs, fn ->
      Proposal.create_changeset(creator, context, attrs)
    end)
  end

  # @spec create(User.t(), attrs :: map) :: {:ok, Proposal.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, attrs) when is_map(attrs) do
    do_create(creator, attrs, fn ->
      Proposal.create_changeset(creator, attrs)
    end)
  end

  def do_create(creator, attrs, changeset_fn) do
    Repo.transact_with(fn ->
      cs = changeset_fn.()

      with {:ok, cs} <- change_eligible_location(cs, attrs),
           {:ok, item} <- Repo.insert(cs),
           act_attrs = %{verb: "created", is_local: true},
           # FIXME
           {:ok, activity} <- Activities.create(creator, item, act_attrs),
           :ok <- index(item),
           :ok <- publish(creator, item, activity, :created) do
        {:ok, item}
      end
    end)
  end

  defp publish(creator, proposal, activity, :created) do
    feeds = [
      creator.outbox_id,
      Feeds.instance_outbox_id()
    ]

    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish("create", proposal.id, creator.id)
    end
  end

  defp publish(creator, context, proposal, activity, :created) do
    feeds = [
      context.outbox_id,
      creator.outbox_id,
      Feeds.instance_outbox_id()
    ]

    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish("create", proposal.id, creator.id)
    end
  end

  defp publish(proposal, :updated) do
    # TODO: wrong if edited by admin
    ap_publish("update", proposal.id, proposal.creator_id)
  end

  defp publish(proposal, :deleted) do
    # TODO: wrong if edited by admin
    ap_publish("delete", proposal.id, proposal.creator_id)
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
  # @spec update(%Proposal{}, attrs :: map) :: {:ok, Proposal.t()} | {:error, Changeset.t()}
  def update(%Proposal{} = proposal, attrs) do
    do_update(proposal, attrs, &Proposal.update_changeset(&1, attrs))
  end

  def update(%Proposal{} = proposal, %{id: id} = context, attrs) do
    do_update(proposal, attrs, &Proposal.update_changeset(&1, context, attrs))
  end

  def do_update(proposal, attrs, changeset_fn) do
    Repo.transact_with(fn ->
      proposal =
        Repo.preload(proposal, [
          :eligible_location
        ])

      cs =
        proposal
        |> changeset_fn.()

      with {:ok, cs} <- change_eligible_location(cs, attrs),
           {:ok, proposal} <- Repo.update(cs),
           :ok <- publish(proposal, :updated) do
        {:ok, proposal}
      end
    end)
  end

  def soft_delete(%Proposal{} = proposal) do
    Repo.transact_with(fn ->
      with {:ok, proposal} <- Common.soft_delete(proposal),
           :ok <- publish(proposal, :deleted) do
        {:ok, proposal}
      end
    end)
  end

  defp index(obj) do
    # icon = MoodleNet.Uploads.remote_url_from_id(obj.icon_id)
    object = %{
      "index_type" => "Proposal",
      "id" => obj.id,
      # "canonicalUrl" => obj.actor.canonical_url,
      # "icon" => icon,
      "name" => obj.name,
      "note" => Map.get(obj, :note),
      "createdAt" => obj.published_at
      # "index_instance" => URI.parse(obj.actor.canonical_url).host, # home instance of object
    }

    CommonsPub.Search.Indexer.maybe_index_object(object)

    :ok
  end

  defp change_eligible_location(changeset, %{eligible_location: id}) do
    with {:ok, location} <- Geolocations.one([:default, id: id]) do
      {:ok, Proposal.change_eligible_location(changeset, location)}
    end
  end

  defp change_eligible_location(changeset, _attrs), do: {:ok, changeset}
end
