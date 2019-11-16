# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.AuthPayload do
  @enforce_keys [:token, :me]
  defstruct @enforce_keys

  def new(token, me), do: %__MODULE__{token: token, me: me}
end
