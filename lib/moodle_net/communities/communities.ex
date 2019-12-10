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
      order_by: [desc: fc.count, desc: a.updated_at, desc: a.id]
    )
  end

  @doc "Fetches a public, non-deleted community by id"
  def fetch(id) when is_binary(id) do
    with {:ok, comm} <- Repo.single(fetch_q(id)) do
      {:ok, preload(comm)}
    end
  end

  defp fetch_q(id) do
    from(c in Community,
      join: a in assoc(c, :actor),
      where: c.id == ^id,
      where: not is_nil(c.published_at),
      where: is_nil(c.deleted_at),
      where: is_nil(c.disabled_at),
      preload: [:actor]
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
      where: is_nil(c.disabled_at)
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
           {:ok, inbox} <- Feeds.create_feed(),
           {:ok, outbox} <- Feeds.create_feed(),
           attrs2 = Map.merge(attrs, %{inbox_id: inbox.id, outbox_id: outbox.id}),
           {:ok, comm} <- insert_community(creator, actor, attrs),
           {:ok, activity} <- Activities.create(comm, creator, %{verb: "create", is_local: true}),
           :ok <- publish_create(creator, comm, activity) do
        {:ok, %{ comm | actor: actor }}
      end
    end)
  end

  @spec create_remote(User.t(), attrs :: map) :: {:ok, Community.t()} | {:error, Changeset.t()}
  def create_remote(%User{} = creator, %{} = attrs) do
    Repo.transact_with(fn ->
      with {:ok, actor} <- Actors.create(attrs),
           {:ok, outbox} <- Feeds.create_feed(),
           attrs2 = Map.put(attrs, :outbox_id, outbox.id),
           {:ok, comm} <- insert_community(creator, actor, attrs),
           {:ok, activity} <- Activities.create(comm, creator, %{verb: "create", is_local: true}),
           :ok <- publish_create(creator, comm, activity) do
        {:ok, %{ comm | actor: actor }}
      end
    end)
  end

  defp insert_community(creator, actor, attrs) do
    Community.create_changeset(creator, actor, attrs)
    |> Repo.insert()
  end

  defp publish_create(creator, community, activity) do
    Feeds.publish_to_feeds([community, creator], activity)
  end
  # defp publish_update(community, activity) do
  # end

  @spec update(%Community{}, attrs :: map) :: {:ok, Community.t()} | {:error, Changeset.t()}
  def update(%Community{} = community, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      community = preload(community)
      with {:ok, comm} <- Repo.update(Community.update_changeset(community, attrs)),
           {:ok, actor} <- Actors.update(community.actor, attrs) do
        {:ok, %{ comm | actor: actor}}
      end
    end)
  end

  def outbox(%Community{}=community, opts \\ %{}) do
    Feeds.feed_activities([community.outbox_id], opts)
  end

  def soft_delete(%Community{} = community), do: Common.soft_delete(community)

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
