# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.InvalidLimitError do
  @enforce_keys [:limit]
  defstruct @enforce_keys

  @type t :: %__MODULE__{ limit: pos_integer }

  @doc "Create a new InvalidLimitError with the given limit"
  @spec new(limit :: pos_integer()) :: t
  def new(limit), do: %__MODULE__{limit: limit}
end
