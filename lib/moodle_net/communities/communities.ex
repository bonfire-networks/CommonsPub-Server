# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Communities do
  import Ecto.Query, only: [from: 2]
  alias Ecto.Changeset

  alias MoodleNet.Actors.{
    Actor,
    ActorFollowerCount
  }

  alias Ecto.Association.NotLoaded
  alias MoodleNet.{Activities, Actors, Collections, Common, Feeds, Meta, Repo, Users}
  alias MoodleNet.Common.Query
  alias MoodleNet.Communities.{Community, Outbox}
  alias MoodleNet.Localisation.Language
  alias MoodleNet.Users.User

  # def count_for_list(), do: Repo.one(count_for_list_q())

  @doc "Lists public, non-deleted communities by follower count"
  def list() do
    Enum.map(Repo.all(list_q()), fn {community, actor, count} ->
      %{community | actor: actor, follower_count: count}
    end)
  end

  def count_for_list(), do: Repo.one(count_for_list_q())

  defp count_for_list_q() do
    from(c in Community,
      where: not is_nil(c.published_at),
      where: is_nil(c.deleted_at),
      select: count(c),
    )
  end

  def list_q() do
    from(c in Community,
      join: a in assoc(c, :actor),
      left_join: fc in assoc(c, :follower_count),
      where: not is_nil(c.published_at),
      where: is_nil(c.deleted_at),
      select: {c, a, fc},
      order_by: [desc: fc.count, desc: a.updated_at, desc: a.id],
    )
  end

  @doc "Fetches a public, non-deleted community by id"
  def fetch(id) when is_binary(id), do: Repo.single(fetch_q(id))

  defp fetch_q(id) do
    from(c in Community,
      join: a in assoc(c, :actor),
      where: c.id == ^id,
      where: not is_nil(c.published_at),
      where: is_nil(c.deleted_at),
      where: is_nil(c.disabled_at),
      select: c,
      preload: [actor: a]
    )
  end

  def fetch_by_username(username) when is_binary(username) do
    Repo.transact_with(fn ->
      with {:ok, comm} <- Repo.single(fetch_by_username_q(username)) do
        {:ok, preload(comm)}
      end
    end)
  end

  defp fetch_by_username_q(username) when is_binary(username) do
    from c in Community,
      join: a in assoc(c, :actor),
      where: a.preferred_username == ^username,
      where: not is_nil(c.published_at),
      where: is_nil(c.deleted_at),
      where: is_nil(c.disabled_at),
      preload: [actor: a]
  end

  @doc "Fetches a community by ID, ignoring whether it is public or not."
  @spec fetch_private(id :: binary) :: {:ok, Community.t()} | {:error, NotFoundError.t()}
  def fetch_private(id) when is_binary(id) do
    with {:ok, comm} <- Repo.fetch(Community, id) do
      {:ok, preload(comm)}
    end
  end

  @spec create(User.t(), attrs :: map) :: {:ok, Community.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %{} = attrs) do
    Repo.transact_with(fn ->
      with {:ok, actor} <- Actors.create(attrs),
           {:ok, comm_attrs} <- create_boxes(actor, attrs),
           {:ok, comm} <- insert_community(creator, actor, comm_attrs),
           act_attrs = %{verb: "created", is_local: is_nil(actor.peer_id)},
           {:ok, activity} <- Activities.create(creator, comm, act_attrs),
           :ok <- publish(creator, comm, activity, :created) do
        {:ok, comm}
      end
    end)
  end

  defp create_boxes(%{peer_id: nil}, attrs), do: create_local_boxes(attrs)
  defp create_boxes(%{peer_id: _}, attrs), do: create_remote_boxes(attrs)

  defp create_local_boxes(attrs) do
    with {:ok, inbox} <- Feeds.create_feed(),
         {:ok, outbox} <- Feeds.create_feed() do
      extra = %{inbox_id: inbox.id, outbox_id: outbox.id}
      {:ok, Map.merge(attrs, extra)}
    end
  end

  defp create_remote_boxes(attrs) do
    with {:ok, outbox} <- Feeds.create_feed() do
      {:ok, Map.put(attrs, :outbox_id, outbox.id)}
    end
  end

  defp insert_community(creator, actor, attrs) do
    with {:ok, community} <- Repo.insert(Community.create_changeset(creator, actor, attrs)) do
      {:ok, %{ community | actor: actor }}
    end
  end

  defp publish(creator, community, activity, :created) do
    feeds = [community.outbox_id, creator.outbox_id]
    with :ok <- Feeds.publish_to_feeds(feeds, activity) do
      ap_publish(community.id, creator.id, community.actor.peer_id)
    end
  end
  defp publish(community, :updated) do
    ap_publish(community.id, community.creator_id, community.actor.peer_id) # TODO: wrong if edited by admin
  end
  defp publish(community, :deleted) do
    ap_publish(community.id, community.creator_id, community.actor.peer_id) # TODO: wrong if edited by admin
  end

  defp ap_publish(context_id, user_id, nil) do
    MoodleNet.FeedPublisher.publish(%{
      "context_id" => context_id,
      "user_id" => user_id,
    })
  end
  defp ap_publish(_, _, _), do: :ok

  @spec update(%Community{}, attrs :: map) :: {:ok, Community.t()} | {:error, Changeset.t()}
  def update(%Community{} = community, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      with {:ok, comm} <- Repo.update(Community.update_changeset(community, attrs)),
           {:ok, actor} <- Actors.update(community.actor, attrs),
           act_attrs = %{verb: "updated", is_local: is_nil(community.actor.peer_id)},
           community = %{ comm | actor: actor },
           :ok <- publish(community, :updated)  do
        {:ok, %{ comm | actor: actor}}
      end
    end)
  end

  def outbox(%Community{}=community, opts \\ %{}) do
    Feeds.feed_activities([community.outbox_id], opts)
  end

  def soft_delete(%Community{} = community) do
    Repo.transact_with(fn ->
      with {:ok, community} <- Common.soft_delete(community),
           :ok <- publish(community, :deleted) do
        {:ok, community}
      end
    end)
  end

  def preload(%Community{} = community, opts \\ []) do
    community
    |> Repo.preload(:actor, opts)
  end

  def preload_creator(%Community{} = community, opts \\ []) do
    community
    |> Repo.preload(:creator, opts)
  end

  def fetch_creator(%Community{creator_id: id, creator: %NotLoaded{}}), do: Users.fetch(id)
  def fetch_creator(%Community{creator: creator}), do: {:ok, creator}

end
