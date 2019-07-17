# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Communities do

  alias MoodleNet.Common
  alias MoodleNet.Communities.CommunityFlag

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

end
