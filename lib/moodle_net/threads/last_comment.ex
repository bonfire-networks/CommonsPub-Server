# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Threads.LastComment do
  @moduledoc """
  The most recently created comment for a thread
  """
  use MoodleNet.Common.Schema
  alias MoodleNet.Threads.{Comment, Thread}

  view_schema "mn_thread_last_comment" do
    belongs_to :thread, Thread, primary_key: true
    belongs_to :comment, Comment
  end

end
