# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Resources do

  alias MoodleNet.Common
  alias MoodleNet.Resources.ResourceFlag

  @doc """
  Likes a resource with a given reason
  {:ok, ResourceLike} | {:error, reason}
  """
  def like(actor, resource),
    do: Common.like(ResourceLike, :like_resource?, actor, resource)

  @doc """
  Undoes a previous like
  {:ok, ResourceLike} | {:error, term()}
  """
  def undo_like(actor, resource), do: Common.undo_like(ResourceLike, actor, resource)

  @doc """
  Lists all ResourceLike matching the provided optional filters.
  Filters:
    :open :: boolean
  """
  def all_likes(actor, filters \\ %{}),
    do: Common.likes(ResourceLike, :list_resource_likes?, actor, filters)

  @doc """
  Flags a resource with a given reason
  {:ok, ResourceFlag} | {:error, reason}
  """
  def flag(actor, resource, attrs=%{reason: _}),
    do: Common.flag(ResourceFlag, :flag_resource?, actor, resource, attrs)

  @doc """
  Undoes a previous flag
  {:ok, ResourceFlag} | {:error, term()}
  """
  def undo_flag(actor, resource), do: Common.undo_flag(ResourceFlag, actor, resource)

  @doc """
  Lists all ResourceFlag matching the provided optional filters.
  Filters:
    :open :: boolean
  """
  def all_flags(actor, filters \\ %{}),
    do: Common.flags(ResourceFlag, :list_resource_flags?, actor, filters)

end
