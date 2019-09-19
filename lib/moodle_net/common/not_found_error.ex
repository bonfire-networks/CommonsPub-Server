# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.NotFoundError do
  @enforce_keys [:key]
  defstruct @enforce_keys

  @type t :: %__MODULE__{ key: term() }

  @spec new(term()) :: t()
  @doc "Create a new NotFoundError with the given key"
  def new(key), do: %__MODULE__{key: key}
end
