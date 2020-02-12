# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Batching do
  alias MoodleNet.Batching.PageOpts
  alias Ecto.Changeset

  def full_page_opts(opts) do
    Changeset.apply_action(PageOpts.full_changeset(opts), :create)
  end

  def limit_page_opts(opts) do
    Changeset.apply_action(PageOpts.full_changeset(opts), :create)
  end

end
