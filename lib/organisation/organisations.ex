# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Organisation.Organisations do
  alias MoodleNet.{Activities, Actors, Common, Feeds, Follows, Repo}
  alias MoodleNet.GraphQL.{Fields, Page}
  alias MoodleNet.Common.Contexts
  alias Organisation
  alias Organisation.{Queries}
  alias MoodleNet.Communities.Community
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.Users.User

  def cursor(:followers), do: &[&1.follower_count, &1.id]
  def test_cursor(:followers), do: &[&1["followerCount"], &1["id"]]

  @doc """
  Retrieves a single organisation by arbitrary filters.
  Used by:
  * GraphQL Item queries
  * ActivityPub integration
  * Various parts of the codebase that need to query for organisations (inc. tests)
  """
  def one(filters), do: Repo.single(Queries.query(Organisation, filters))

  @doc """
  Retrieves a list of organisations by arbitrary filters.
  Used by:
  * Various parts of the codebase that need to query for organisations (inc. tests)
  """
  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Organisation, filters))}

  def fields(group_fn, filters \\ [])
  when is_function(group_fn, 1) do
    {:ok, fields} = many(filters)
    {:ok, Fields.new(fields, group_fn)}
  end

  @doc """
  Retrieves an Page of organisations according to various filters

  Used by:
  * GraphQL resolver single-parent resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def page(cursor_fn, %{}=page_opts, base_filters, data_filters, count_filters) do
    base_q = Queries.query(Organisation, base_filters)
    data_q = Queries.filter(base_q, data_filters)
    count_q = Queries.filter(base_q, count_filters)
    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, Page.new(data, counts, cursor_fn, page_opts)}
    end
  end

  @doc """
  Retrieves an Pages of organisations according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def pages(cursor_fn, group_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def pages(cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters) do
    Contexts.pages Queries, Organisation,
      cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters
  end

  ## mutations
  defp prepend_comm_username(%{actor: %{preferred_username: comm_username}}, %{preferred_username: org_username}) do
    comm_username <> org_username
  end

  defp prepend_comm_username(_community, _attr), do: nil

  @spec create(User.t(), attrs :: map) :: {:ok, Organisation.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, attrs) when is_map(attrs) do

    Repo.transact_with(fn ->
      with {:ok, actor} <- Actors.create(attrs),
           {:ok, org_attrs} <- create_boxes(actor, attrs),
           {:ok, org} <- insert_organisation(creator, actor, org_attrs),
           act_attrs = %{verb: "created", is_local: true},
           {:ok, activity} <- Activities.create(creator, org, act_attrs),
           :ok <- publish(creator, org, activity, :created),
           {:ok, _follow} <- Follows.create(creator, org, %{is_local: true}) do 
        {:ok, org}
      end
    end)
  end

  @spec create(User.t(), Community.t(), attrs :: map) :: {:ok, Organisation.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %Community{} = community, attrs) when is_map(attrs) do

    Repo.transact_with(fn ->
      with {:ok, actor} <- Actors.create(attrs),
           {:ok, org_attrs} <- create_boxes(actor, attrs),
           {:ok, org} <- insert_organisation_with_community(creator, community, actor, org_attrs),
           act_attrs = %{verb: "created", is_local: true},
           {:ok, activity} <- Activities.create(creator, org, act_attrs),
           :ok <- publish(creator, community, org, activity, :created),
           {:ok, _follow} <- Follows.create(creator, org, %{is_local: true}) do
        {:ok, org}
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

  defp insert_organisation(creator, actor, attrs) do
    cs = Organisation.create_changeset(creator, actor, attrs)
    with {:ok, org} <- Repo.insert(cs), do: {:ok, %{ org | actor: actor }}
  end

  defp insert_organisation_with_community(creator, community, actor, attrs) do
    cs = Organisation.create_changeset_with_community(creator, community, actor, attrs)
    with {:ok, org} <- Repo.insert(cs), do: {:ok, %{ org | actor: actor }}
  end

  defp publish(creator, organisation, activity, :created) do
    feeds = [
      creator.outbox_id,
      organisation.outbox_id, Feeds.instance_outbox_id(),
    ]
    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish(organisation.id, creator.id, organisation.actor.peer_id)
    end
  end

  defp publish(creator, community, organisation, activity, :created) do
    feeds = [
      community.outbox_id, creator.outbox_id,
      organisation.outbox_id, Feeds.instance_outbox_id(),
    ]
    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish(organisation.id, creator.id, organisation.actor.peer_id)
    end
  end

  defp publish(organisation, :updated) do
    ap_publish(organisation.id, organisation.creator_id, organisation.actor.peer_id) # TODO: wrong if edited by admin
  end
  defp publish(organisation, :deleted) do
    ap_publish(organisation.id, organisation.creator_id, organisation.actor.peer_id) # TODO: wrong if edited by admin
  end

  defp ap_publish(context_id, user_id, nil) do
    MoodleNet.FeedPublisher.publish(%{
      "context_id" => context_id,
      "user_id" => user_id,
    })
  end
  defp ap_publish(_, _, _), do: :ok

  # TODO: take the user who is performing the update
  @spec update(%Organisation{}, attrs :: map) :: {:ok, Organisation.t()} | {:error, Changeset.t()}
  def update(%Organisation{} = organisation, attrs) do
    Repo.transact_with(fn ->
      organisation = Repo.preload(organisation, :community)
      with {:ok, organisation} <- Repo.update(Organisation.update_changeset(organisation, attrs)),
           {:ok, actor} <- Actors.update(organisation.actor, attrs),
           :ok <- publish(organisation, :updated) do
        {:ok, %{ organisation | actor: actor }}
      end
    end)
  end

  def soft_delete(%Organisation{} = organisation) do
    Repo.transact_with(fn ->
      with {:ok, organisation} <- Common.soft_delete(organisation),
           :ok <- publish(organisation, :deleted) do
        {:ok, organisation}
      end
    end)
  end

end
