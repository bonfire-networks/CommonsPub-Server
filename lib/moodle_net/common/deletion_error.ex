# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.DeletionError do
  @enforce_keys [:changeset]
  defstruct @enforce_keys

  alias Ecto.Changeset

  @type t :: %__MODULE__{ changeset: Changeset.t() }

  @spec new(term()) :: t()
  @doc "Create a new DeletionError with the given changeset"
  def new(changeset) do
    %__MODULE__{changeset: changeset}
  end
  
end
