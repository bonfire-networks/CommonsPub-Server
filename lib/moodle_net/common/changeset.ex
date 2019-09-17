# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.Changeset do
  @moduledoc "Helper functions for changesets"
  
  alias Ecto.Changeset

  @spec meta_pointer_constraint(Changeset.t()) :: Changeset.t()
  @doc "Adds a foreign key constraint for pointer on the id"
  def meta_pointer_constraint(changeset),
    do: Changeset.foreign_key_constraint(changeset, :id)
  
end
