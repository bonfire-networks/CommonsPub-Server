# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Communities do

  alias MoodleNet.Common
  alias MoodleNet.Communities.{
    CommunityFlag,
    CommunityLike,
  }

  @doc """
  Likes a community with a given reason
  {:ok, CommunityLike} | {:error, reason}
  """
  def like(actor, community),
    do: Common.like(CommunityLike, :like_community?, actor, community)

  @doc """
  Undoes a previous like
  {:ok, CommunityLike} | {:error, term()}
  """
  def undo_like(actor, community), do: Common.undo_like(CommunityLike, actor, community)

  @doc """
  Lists all CommunityLike matching the provided optional filters.
  Filters:
    :open :: boolean
  """
  def all_likes(actor, filters \\ %{}),
    do: Common.likes(CommunityLike, :list_community_likes?, actor, filters)


  @doc """
  Flags a community with a given reason
  {:ok, CommunityFlag} | {:error, reason}
  """
  def flag(actor, community, attrs=%{reason: _}),
    do: Common.flag(CommunityFlag, :flag_community?, actor, community, attrs)

  @doc """
  Undoes a previous flag
  {:ok, CommunityFlag} | {:error, term()}
  """
  def undo_flag(actor, community), do: Common.undo_flag(CommunityFlag, actor, community)

  @doc """
  Lists all CommunityFlag matching the provided optional filters.
  Filters:
    :open :: boolean
  """
  def all_flags(actor, filters \\ %{}),
    do: Common.flags(CommunityFlag, :list_community_flags?, actor, filters)

  def members_query(%Community{}=community, %User{}=user, opts \\ []) do
    
    |> Common.paginate(opts)
  end


  @doc ""
  def members(%Community{}=community, %User{}=user, opts \\ []) do
    members_query(community, user)
    |> Repo.all()
  end
end
