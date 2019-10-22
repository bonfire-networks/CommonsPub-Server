# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.OAuth.UserEmailNotConfirmedError do
  @enforce_keys [:user]
  defstruct @enforce_keys

  alias MoodleNet.Users.User

  @type t :: %__MODULE__{ user: %User{} }

  @spec new(term) :: t
  @doc "Create a new UserEmailNotConfirmedError with the given user"
  def new(user), do: %__MODULE__{user: user}
  
end
