# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.AlreadyLikedError do
  @enforce_keys [:id]
  defstruct @enforce_keys

  @type t :: %__MODULE__{id: binary}

  @doc "Create a new AlreadyLikedError"
  @spec new(id :: binary) :: t
  def new(id) when is_binary(id), do: %__MODULE__{id: id}
end
