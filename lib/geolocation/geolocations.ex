# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Geolocation.Geolocations do
  alias MoodleNet.{Activities, Actors, Common, Feeds, Follows, Repo}
  alias MoodleNet.GraphQL.{Fields, Page}
  alias MoodleNet.Common.Contexts
  alias Geolocation
  alias Geolocation.Queries
  alias MoodleNet.Communities.Community
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.Users.User

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
  def page(cursor_fn, %{}=page_opts, base_filters, data_filters, count_filters) do
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
  def pages(cursor_fn, group_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def pages(cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters) do
    Contexts.pages Queries, Geolocation,
      cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters
  end

  ## mutations
  # defp prepend_comm_username(%{actor: %{preferred_username: comm_username}}, %{preferred_username: item_username}) do
  #   comm_username <> item_username
  # end

  # defp prepend_comm_username(_community, _attr), do: nil

  @spec create(User.t(), Community.t(), attrs :: map) :: {:ok, Geolocation.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %Community{} = community, attrs) when is_map(attrs) do
    # preferred_username = prepend_comm_username(community, attrs)
    # attrs = Map.put(attrs, :preferred_username, preferred_username)

    Repo.transact_with(fn ->
      with {:ok, actor} <- Actors.create(attrs),
           {:ok, item_attrs} <- create_boxes(actor, attrs),
           {:ok, item} <- insert_geolocation(creator, community, actor, item_attrs) do
          #  act_attrs = %{verb: "created", is_local: true},
          #  {:ok, activity} <- Activities.create(creator, item, act_attrs), #FIXME
          #  :ok <- publish(creator, community, item, activity, :created),
          #  {:ok, _follow} <- Follows.create(creator, item, %{is_local: true}) 
          # do
            {:ok, item}
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
    with {:ok, item} <- Repo.insert(cs), do: {:ok, %{ item | actor: actor }}
  end

  defp publish(creator, community, geolocation, activity, :created) do
    feeds = [
      community.outbox_id, creator.outbox_id,
      geolocation.outbox_id, Feeds.instance_outbox_id(),
    ]
    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish(geolocation.id, creator.id, geolocation.actor.peer_id)
    end
  end
  defp publish(geolocation, :updated) do
    ap_publish(geolocation.id, geolocation.creator_id, geolocation.actor.peer_id) # TODO: wrong if edited by admin
  end
  defp publish(geolocation, :deleted) do
    ap_publish(geolocation.id, geolocation.creator_id, geolocation.actor.peer_id) # TODO: wrong if edited by admin
  end

  defp ap_publish(context_id, user_id, nil) do
    MoodleNet.FeedPublisher.publish(%{
      "context_id" => context_id,
      "user_id" => user_id,
    })
  end
  defp ap_publish(_, _, _), do: :ok

  # TODO: take the user who is performing the update
  @spec update(%Geolocation{}, attrs :: map) :: {:ok, Geolocation.t()} | {:error, Changeset.t()}
  def update(%Geolocation{} = geolocation, attrs) do
    Repo.transact_with(fn ->
      geolocation = Repo.preload(geolocation, :community)
      with {:ok, geolocation} <- Repo.update(Geolocation.update_changeset(geolocation, attrs)),
           {:ok, actor} <- Actors.update(geolocation.actor, attrs),
           :ok <- publish(geolocation, :updated) do
        {:ok, %{ geolocation | actor: actor }}
      end
    end)
  end

  # def soft_delete(%Geolocation{} = geolocation) do
  #   Repo.transact_with(fn ->
  #     with {:ok, geolocation} <- Common.soft_delete(geolocation),
  #          :ok <- publish(geolocation, :deleted) do
  #       {:ok, geolocation}
  #     end
  #   end)
  # end

end
