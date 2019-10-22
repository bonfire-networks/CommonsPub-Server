# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.OAuth.AuthorizationExpiredError do
  @enforce_keys [:authorization]
  defstruct @enforce_keys

  alias MoodleNet.OAuth.Authorization

  @type t :: %__MODULE__{ authorization: %Authorization{} }

  @spec new(term) :: t
  @doc "Create a new AuthorizationExpiredError with the given authorization"
  def new(authorization), do: %__MODULE__{authorization: authorization}
  
end
