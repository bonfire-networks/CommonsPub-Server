# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Batching.EdgesPage do
  @enforce_keys ~w(page_info total_count edges)a
  defstruct @enforce_keys

  use MoodleNet.Common.Metadata
  alias MoodleNet.Batching.{Edge, EdgesPage, PageInfo}

  @type t :: %EdgesPage{
    page_info: PageInfo.t,
    total_count: non_neg_integer,
    edges: [Edge.t],
  }

  @spec new(data :: [term], total_count :: non_neg_integer, cursor_fn :: (map -> binary)) :: t
  @will_break_when :privacy
  def new(data, total_count, cursor_fn)
  when is_list(data) and is_integer(total_count) and total_count >= 0
  and is_function(cursor_fn, 1) do
    edges = Enum.map(data, &Edge.new(&1, cursor_fn))
    page_info = PageInfo.new(edges)
    total_count = Enum.count(edges)
    %EdgesPage{page_info: page_info, total_count: total_count, edges: edges}
  end

end
