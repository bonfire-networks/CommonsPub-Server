# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.TokenAlreadyClaimedError do
  @enforce_keys []
  defstruct @enforce_keys

  @type t :: %__MODULE__{}

  @doc "Create a new TokenAlreadyClaimedError"
  @spec new() :: t
  def new(), do: %__MODULE__{}
end
