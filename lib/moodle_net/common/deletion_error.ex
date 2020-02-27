# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.DeletionError do
  @enforce_keys [:changeset]
  defstruct @enforce_keys

  alias Ecto.Changeset
  alias MoodleNet.Common.DeletionError

  @type t :: %__MODULE__{ changeset: Changeset.t() }

  @spec new(term) :: t
  @doc "Create a new DeletionError"
  def new(changeset), do: %DeletionError{ changeset: changeset }
  
end
