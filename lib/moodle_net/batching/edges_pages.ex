# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Batching.EdgesPages do
  @enforce_keys ~w(data counts cursor_fn)a
  defstruct @enforce_keys

  alias MoodleNet.Batching.{EdgesPage, EdgesPages}

  @type data :: %{term => term}
  @type counts :: %{term => non_neg_integer}
  @type t :: %EdgesPages{data: data, counts: counts, cursor_fn: (map -> binary)}
  
  @doc """
  Create a new EdgesPages from some data rows, count rows and a
  grouping key. Groups the data by the grouping key on insertion and
  turns the counts into a map ready for lookup on a per-row basis.

  Note: if the grouping key is not present in the returned data rows,
  this function will crash. Our intuition is that this would mean an
  error in the calling code, so we would rather raise it early.
  """
  def new(data_rows, count_rows, group_fn, cursor_fn)
  when is_function(group_fn, 1) and is_function(cursor_fn, 1) do
    data = Enum.group_by(data_rows, group_fn)
    counts = Map.new(count_rows)
    %EdgesPages{data: data, counts: counts, cursor_fn: cursor_fn}
  end

  @doc "Returns an EdgesPage for the given key, defaulting to an empty one"
  def get(%EdgesPages{data: data, counts: counts, cursor_fn: cursor_fn}, key) do
    {:ok, EdgesPage.new(Map.get(data, key, []), Map.get(counts, key, 0), cursor_fn)}
  end

  @doc """
  Returns a post-batch callback (i.e. the third argument to batch/3)
  for a key which calls get() with the callback param and the key
  """
  def getter(key) do
    fn edge_lists -> get(edge_lists, key) end
  end

end
