# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.Me do
  @enforce_keys [:user]
  defstruct @enforce_keys

  def new(user) do
    %__MODULE__{user: user}
  end

end
