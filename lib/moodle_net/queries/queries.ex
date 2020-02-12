# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Queries do

  alias Ecto.Changeset
  alias MoodleNet.Queries
  alias MoodleNet.Queries.PageOpts

  def page_opts(fields, opts \\ %{})
  def page_opts(%{}=fields, %{}=opts) do
    Changeset.apply_action(PageOpts.changeset(fields, opts), :create)
  end

end
