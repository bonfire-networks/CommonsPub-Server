# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.TokenAlreadyClaimedError do
  @enforce_keys [:token]
  defstruct @enforce_keys

  @type t :: %__MODULE__{ token: term }

  @doc "Create a new TokenAlreadyClaimedError with the given token"
  @spec new(term) :: t
  def new(token), do: %__MODULE__{token: token}
end
