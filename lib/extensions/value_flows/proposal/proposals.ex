# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Proposal.Proposals do
  alias CommonsPub.{Activities, Common, Feeds, Repo}
  alias CommonsPub.GraphQL.{Fields, Page}
  alias CommonsPub.Contexts
  alias CommonsPub.Feeds.FeedActivities
  alias CommonsPub.Users.User

  alias Geolocation.Geolocations
  # alias Measurement.Measure
  alias ValueFlows.Proposal
  alias ValueFlows.Proposal

  alias ValueFlows.Proposal.{
    ProposedTo,
    ProposedToQueries,
    ProposedIntentQueries,
    ProposedIntent,
    Queries
  }

  alias ValueFlows.Planning.Intent

  # use Assertions.AbsintheCase, async: true, schema: ValueFlows.Schema
  # import Assertions.Absinthe, only: [document_for: 4]

  @schema CommonsPub.Web.GraphQL.Schema

  def cursor(), do: &[&1.id]
  def test_cursor(), do: &[&1["id"]]

  @doc """
  Retrieves a single one by arbitrary filters.
  Used by:
  * GraphQL Item queries
  * ActivityPub integration
  * Various parts of the codebase that need to query for this (inc. tests)
  """
  def one(filters), do: Repo.single(Queries.query(Proposal, filters))

  @spec one_proposed_intent(filters :: [any]) :: {:ok, ProposedIntent.t()} | {:error, term}
  def one_proposed_intent(filters),
    do: Repo.single(ProposedIntentQueries.query(ProposedIntent, filters))

  @spec one_proposed_to(filters :: [any]) :: {:ok, ProposedTo.t()} | {:error, term}
  def one_proposed_to(filters),
    do: Repo.single(ProposedToQueries.query(ProposedTo, filters))

  @doc """
  Retrieves a list of them by arbitrary filters.
  Used by:
  * Various parts of the codebase that need to query for this (inc. tests)
  """
  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Proposal, filters))}

  @spec many_proposed_intents(filters :: [any]) :: {:ok, [ProposedIntent.t()]} | {:error, term}
  def many_proposed_intents(filters \\ []),
    do: {:ok, Repo.all(ProposedIntentQueries.query(ProposedIntent, filters))}

  @spec many_proposed_to(filters :: [any]) :: {:ok, [ProposedTo]} | {:error, term}
  def many_proposed_to(filters \\ []),
    do: {:ok, Repo.all(ProposedToQueries.query(ProposedTo, filters))}

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

  def preloads(proposal) do
    CommonsPub.Repo.maybe_preload(proposal, [
      :context,
      :eligible_location,
      :creator
      # :proposed_to,
      # :publishes
    ])
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
      CommonsPub.Feeds.outbox_id(creator),
      Feeds.instance_outbox_id()
    ]

    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish("create", proposal.id, creator.id)
    end
  end

  defp publish(creator, context, proposal, activity, :created) do
    feeds = [
      context.outbox_id,
      CommonsPub.Feeds.outbox_id(creator),
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
    CommonsPub.Workers.APPublishWorker.enqueue(verb, %{
      "context_id" => context_id,
      "user_id" => user_id
    })

    :ok
  end

  # TODO: take the user who is performing the update
  # @spec update(%Proposal{}, attrs :: map) :: {:ok, Proposal.t()} | {:error, Changeset.t()}
  def update(%Proposal{} = proposal, attrs) do
    do_update(proposal, attrs, &Proposal.update_changeset(&1, attrs))
  end

  def update(%Proposal{} = proposal, %{id: _id} = context, attrs) do
    do_update(proposal, attrs, &Proposal.update_changeset(&1, context, attrs))
  end

  def do_update(proposal, attrs, changeset_fn) do
    Repo.transact_with(fn ->
      proposal = preloads(proposal)

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
      with {:ok, proposal} <- Common.Deletion.soft_delete(proposal),
           :ok <- publish(proposal, :deleted) do
        {:ok, proposal}
      end
    end)
  end

  @spec propose_intent(Proposal.t(), Intent.t(), map) ::
          {:ok, ProposedIntent.t()} | {:error, term}
  def propose_intent(%Proposal{} = proposal, %Intent{} = intent, attrs) do
    Repo.insert(ProposedIntent.changeset(proposal, intent, attrs))
  end

  @spec delete_proposed_intent(ProposedIntent.t()) :: {:ok, ProposedIntent.t()} | {:error, term}
  def delete_proposed_intent(%ProposedIntent{} = proposed_intent) do
    Common.Deletion.soft_delete(proposed_intent)
  end

  # if you like it then you should put a ring on it
  @spec propose_to(any, Proposal.t()) :: {:ok, ProposedTo.t()} | {:error, term}
  def propose_to(proposed_to, %Proposal{} = proposed) do
    Repo.insert(ProposedTo.changeset(proposed_to, proposed))
  end

  @spec delete_proposed_to(ProposedTo.t()) :: {:ok, ProposedTo.t()} | {:error, term}
  def delete_proposed_to(proposed_to), do: Common.Deletion.soft_delete(proposed_to)

  def indexing_object_format(obj) do
    # icon = CommonsPub.Uploads.remote_url_from_id(obj.icon_id)
    # image = CommonsPub.Uploads.remote_url_from_id(obj.image_id)

    %{
      "index_type" => "Proposal",
      "id" => obj.id,
      # "canonicalUrl" => obj.canonical_url,
      # "icon" => icon,
      "name" => obj.name,
      "summary" => Map.get(obj, :note),
      "published_at" => obj.published_at,
      "creator" => CommonsPub.Search.Indexer.format_creator(obj)
      # "index_instance" => URI.parse(obj.canonical_url).host, # home instance of object
    }
  end

  defp index(obj) do
    object = indexing_object_format(obj)

    CommonsPub.Search.Indexer.maybe_index_object(object)

    :ok
  end

  @ignore [
    :communities,
    :collections,
    :my_like,
    :my_flag,
    :unit_based,
    :feature_count,
    :follower_count,
    :is_local,
    :is_disabled,
    :page_info,
    :edges,
    :threads,
    :outbox,
    :inbox,
    :followers,
    :community_follows
  ]

  def fields_filter(e) do
    # IO.inspect(e)

    case e do
      {key, {key2, val}} ->
        if key not in @ignore and key2 not in @ignore and is_list(val) do
          {key, {key2, for(n <- val, do: fields_filter(n))}}
          # else
          #   IO.inspect(hmm1: e)
        end

      {key, val} ->
        if key not in @ignore and is_list(val) do
          {key, for(n <- val, do: fields_filter(n))}
          # else
          #   IO.inspect(hmm2: e)
        end

      _ ->
        if e not in @ignore, do: e
    end
  end

  def ap_object_prepare(id) do
    # with obj <- graphql_get_proposal_attempt3(id) do
    with obj <-
           CommonsPub.Web.GraphQL.QueryHelper.run_query_id(
             id,
             @schema,
             :proposal,
             4,
             &fields_filter/1
           ) do
      Map.merge(
        %{
          "type" => "ValueFlows:Proposal"
          # "canonicalUrl" => obj.canonical_url,
          # "icon" => icon,
          # "published" => obj.hasBeginning
        },
        obj
      )
    end
  end

  def ap_publish_activity("create", %{id: id} = proposal) when is_binary(id) do
    ValueFlows.Util.ap_prepare_activity("create", proposal, ap_object_prepare(id))
  end

  def ap_publish_activity(activity_name, proposal) do
    ValueFlows.Util.ap_prepare_activity(activity_name, proposal, ap_object_prepare(proposal.id))
  end

  defp change_eligible_location(changeset, %{eligible_location: id}) do
    with {:ok, location} <- Geolocations.one([:default, id: id]) do
      {:ok, Proposal.change_eligible_location(changeset, location)}
    end
  end

  defp change_eligible_location(changeset, _attrs), do: {:ok, changeset}
end
