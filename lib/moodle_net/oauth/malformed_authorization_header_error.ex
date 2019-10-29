# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.OAuth.MalformedAuthorizationHeaderError do
  @enforce_keys [:authorization]
  defstruct @enforce_keys

  alias MoodleNet.OAuth.Authorization

  @type t :: %__MODULE__{ authorization: %Authorization{} }

  @spec new(term) :: t
  @doc "Create a new MalformedAuthorizationHeaderError with the given authorization header"
  def new(authorization), do: %__MODULE__{authorization: authorization}
end
