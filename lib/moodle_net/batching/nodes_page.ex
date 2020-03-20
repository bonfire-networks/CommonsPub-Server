# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Batching.NodesPage do
  @enforce_keys ~w(nodes total_count page_info)a
  defstruct @enforce_keys

  use MoodleNet.Common.Metadata
  alias MoodleNet.Batching.{NodesPage, PageInfo}

  @type t :: %NodesPage{nodes: [map], total_count: integer}
  
  @doc "Create a new NodesPage from some data rows and a count"
  @spec new(data :: [map], total_count :: integer, cursor_fn :: (map -> binary)) :: t

  @will_break_when :privacy
  def new(nodes, total_count, cursor_fn)
  when is_list(nodes) and is_integer(total_count) and is_function(cursor_fn, 1) do
    mapped = Enum.map(nodes, fn node -> %{cursor: cursor_fn.(node), node: node} end)
    page_info = PageInfo.new(mapped)
    total_count = Enum.count(nodes)
    %NodesPage{nodes: nodes, total_count: total_count, page_info: page_info}
  end

end
