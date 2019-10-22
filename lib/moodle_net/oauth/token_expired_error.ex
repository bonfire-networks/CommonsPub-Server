# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.OAuth.TokenExpiredError do
  @enforce_keys [:token]
  defstruct @enforce_keys

  alias MoodleNet.OAuth.Token

  @type t :: %__MODULE__{ token: %Token{} }

  @spec new(term) :: t
  @doc "Create a new TokenExpiredError with the given token"
  def new(token), do: %__MODULE__{token: token}
  
end
