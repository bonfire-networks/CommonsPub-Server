# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Comments do

  alias MoodleNet.Common
  alias MoodleNet.Comments.CommentFlag

  @doc """
  Flags a comment with a given reason
  {:ok, CommentFlag} | {:error, reason}
  """
  def flag(actor, comment, attrs=%{reason: _}),
    do: Common.flag(CommentFlag, :flag_comment?, actor, comment, attrs)

  @doc """
  Undoes a previous flag
  {:ok, CommentFlag} | {:error, term()}
  """
  def undo_flag(actor, comment), do: Common.undo_flag(CommentFlag, actor, comment)

  @doc """
  Lists all CommentFlag matching the provided optional filters.
  Filters:
    :open :: boolean
  """
  def all_flags(actor, filters \\ %{}),
    do: Common.flags(CommentFlag, :list_comment_flags?, actor, filters)

end
