# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Batching.PageInfo do
  @moduledoc """
  Information about a subset of the page
  """
  @enforce_keys ~w(start_cursor end_cursor has_previous_page has_next_page)a
  defstruct @enforce_keys
  
  alias MoodleNet.Batching.PageInfo

  @type t :: %PageInfo{
    start_cursor: binary | nil,
    end_cursor: binary | nil,
    has_previous_page: false,
    has_next_page: false
  }

  @spec new([%{cursor: binary}]) :: t
  def new([]) do
    %PageInfo{
      start_cursor: nil,
      end_cursor: nil,
      has_previous_page: false,
      has_next_page: false,
    }
  end
  def new([x]) do
    %PageInfo{
      start_cursor: x.cursor,
      end_cursor: x.cursor,
      has_previous_page: false,
      has_next_page: false,
    }
  end
  def new([x | xs]) do
    %PageInfo{
      start_cursor: x.cursor,
      end_cursor: List.last(xs).cursor,
      has_previous_page: false,
      has_next_page: false,
    }
  end

end
