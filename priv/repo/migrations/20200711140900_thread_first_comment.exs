# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Repo.Migrations.ThreadFirstComment do
  use Ecto.Migration

  def up do
    # first created comment in the thread

    :ok =
      execute("""
      create view mn_thread_first_comment as
      select mn_comment.thread_id as thread_id, min(mn_comment.id) as comment_id
      from mn_comment
      group by mn_comment.thread_id
      """)
  end

  def down do
    :ok = execute("drop view mn_thread_first_comment")
  end
end
