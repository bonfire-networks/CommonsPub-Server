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
  alias MoodleNet.{Actors, Collections, Common, Meta, Repo, Users}
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
      join: a in Actor,
      on: a.id == c.actor_id,
      left_join: fc in assoc(c, :follower_count),
      where: not is_nil(c.published_at),
      where: is_nil(c.deleted_at),
      select: {c, a, fc},
      limit: 100,
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
      where: c.id == ^id,
      where: not is_nil(c.published_at),
      where: is_nil(c.deleted_at),
      where: is_nil(c.disabled_at)
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
           {:ok, comm} <- insert_community(creator, actor, attrs),
           {:ok, _} <- publish_community(comm, "create") do
        {:ok, comm}
      end
    end)
  end

  defp insert_community(creator, actor, attrs) do
    Meta.point_to!(Community)
    |> Community.create_changeset(creator, actor, attrs)
    |> Repo.insert()
  end

  defp publish_community(%Community{} = community, verb) do
    MoodleNet.FeedPublisher.publish(%{
      "verb" => verb,
      "context_id" => community.id,
      "user_id" => community.creator_id,
    })
  end

  @spec update(%Community{}, attrs :: map) :: {:ok, Community.t()} | {:error, Changeset.t()}
  def update(%Community{} = community, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      community = preload(community)
      with {:ok, comm} <- Repo.update(Community.update_changeset(community, attrs)),
           {:ok, actor} <- Actors.update(community.actor, attrs) do
        community = %{ comm | actor: actor}
        {:ok, community}
      end
    end)
  end

<<<<<<< HEAD
  def outbox(%Community{}=community, opts \\ %{}) do
    Repo.all(outbox_q(community, opts))
    |> Repo.preload(:activity)
  end
  def outbox_q(%Community{id: id}=community, _opts) do
    from i in Outbox,
      join: c in assoc(i, :community),
      join: a in assoc(i, :activity),
      where: c.id == ^id,
      where: not is_nil(a.published_at),
      select: i,
      preload: [:activity]
  end
  def count_for_outbox(%Community{}=community, opts \\ %{}) do
    Repo.one(count_for_outbox_q(community, opts))
  end
  def count_for_outbox_q(%Community{id: id}=community, _opts) do
    from i in Outbox,
      join: c in assoc(i, :community),
      join: a in assoc(i, :activity),
      where: c.id == ^id,
      where: not is_nil(a.published_at),
      select: count(i)
  end

  def soft_delete(%Community{} = community), do: Common.soft_delete(community)
=======
  def soft_delete(%Community{} = community) do
    with {:ok, community} <- Common.soft_delete(community),
         {:ok, _} <- publish_community(community, "delete") do
      {:ok, community}
    end
  end
>>>>>>> ecba0d77... Publish event when community, resource or collection is created/deleted

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
