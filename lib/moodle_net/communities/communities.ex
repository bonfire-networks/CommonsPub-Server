# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Communities do
  alias Ecto.Changeset
  alias MoodleNet.Actors.Actor
  alias MoodleNet.{Common, Meta, Repo}
  alias MoodleNet.Communities.Community
  alias MoodleNet.Users.User
  alias MoodleNet.Localisation.Language

  @spec create(Actor.t(), Language.t(), attrs :: map) :: {:ok, Community.t()} | {:error, Changeset.t()}
  def create(%Actor{} = creator, %Language{} = language, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      Meta.point_to!(Community)
      |> Community.create_changeset(creator, language, attrs)
      |> Repo.insert()
    end)
  end

  @spec update(%Community{}, attrs :: map) :: {:ok, Community.t()} | {:error, Changeset.t()}
  def update(%Community{} = community, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      community
      |> Community.update_changeset(attrs)
      |> Repo.update()
    end)
  end

  def join(community, member) do
  end

  def leave(community, member) do
  end

  # @doc """
  # Likes a community with a given reason
  # {:ok, CommunityLike} | {:error, reason}
  # """
  # def like(actor, community),
  #   do: Common.like(CommunityLike, :like_community?, actor, community)

  # @doc """
  # Undoes a previous like
  # {:ok, CommunityLike} | {:error, term()}
  # """
  # def undo_like(actor, community), do: Common.undo_like(CommunityLike, actor, community)

  # @doc """
  # Lists all CommunityLike matching the provided optional filters.
  # Filters:
  #   :open :: boolean
  # """
  # def all_likes(actor, filters \\ %{}),
  #   do: Common.likes(CommunityLike, :list_community_likes?, actor, filters)

  # @doc """
  # Flags a community with a given reason
  # {:ok, CommunityFlag} | {:error, reason}
  # """
  # def flag(actor, community, attrs = %{reason: _}),
  #   do: Common.flag(CommunityFlag, :flag_community?, actor, community, attrs)

  # @doc """
  # Undoes a previous flag
  # {:ok, CommunityFlag} | {:error, term()}
  # """
  # def undo_flag(actor, community), do: Common.undo_flag(CommunityFlag, actor, community)

  # @doc """
  # Lists all CommunityFlag matching the provided optional filters.
  # Filters:
  #   :open :: boolean
  # """
  # def all_flags(actor, filters \\ %{}),
  #   do: Common.flags(CommunityFlag, :list_community_flags?, actor, filters)

  # def members_query(%Community{} = community, %User{} = user, opts \\ []) do
  #   # TODO
  #   community
  #   |> Common.paginate(opts)
  # end

  # @doc ""
  # def members(%Community{} = community, %User{} = user, opts \\ []) do
  #   members_query(community, user)
  #   |> Repo.all()
  # end
end
