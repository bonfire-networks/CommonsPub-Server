# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Collections do

  alias MoodleNet.Common
  alias MoodleNet.Collections.CollectionFlag

  @doc """
  Flags a collection with a given reason
  {:ok, CollectionFlag} | {:error, reason}
  """
  def flag(actor, collection, attrs=%{reason: reason}),
    do: Common.flag(CollectionFlag, :flag_collection?, actor, collection, attrs)

  @doc """
  Undoes a previous flag
  {:ok, CollectionFlag} | {:error, term()}
  """
  def undo_flag(actor, collection), do: Common.undo_flag(CollectionFlag, actor, collection)

  @doc """
  Lists all CollectionFlag matching the provided optional filters.
  Filters:
    :open :: boolean
  """
  def all_flags(actor, filters \\ %{}),
    do: Common.flags(CollectionFlag, :list_collection_flags?, actor, filters)

end
