# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users do

  alias MoodleNet.Common
  alias MoodleNet.Users.UserFlag

  @doc """
  Flags a user with a given reason
  {:ok, UserFlag} | {:error, reason}
  """
  def flag(actor, user, attrs=%{reason: _}),
    do: Common.flag(UserFlag, :flag_user?, actor, user, attrs)

  @doc """
  Undoes a previous flag
  {:ok, UserFlag} | {:error, term()}
  """
  def undo_flag(actor, user), do: Common.undo_flag(UserFlag, actor, user)

  @doc """
  Lists all UserFlag matching the provided optional filters.
  Filters:
    :open :: boolean
  """
  def all_flags(actor, filters \\ %{}),
    do: Common.flags(UserFlag, :list_user_flags?, actor, filters)

end
