# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.Revision do
  alias MoodleNet.Repo

  def insert(module, parent, attrs) do
    parent_keys =
      parent
      |> Map.keys()
      |> Enum.map(&Atom.to_string/1)

    revision_attrs = Map.drop(attrs, parent_keys)

    parent
    |> module.create_changeset(revision_attrs)
    |> Repo.insert()
  end
end
