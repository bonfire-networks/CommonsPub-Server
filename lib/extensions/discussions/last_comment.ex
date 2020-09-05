# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Threads.LastComment do
  @moduledoc """
  The most recently created comment for a thread
  """
  use CommonsPub.Common.Schema
  alias CommonsPub.Threads.{Comment, Thread}

  view_schema "mn_thread_last_comment" do
    belongs_to(:thread, Thread, primary_key: true)
    belongs_to(:comment, Comment)
  end
end
