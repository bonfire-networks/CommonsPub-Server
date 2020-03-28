# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.Metadata do

  defmacro __using__(_) do
    quote do
      Module.register_attribute(__MODULE__, :will_break_when, accumulate: true)
    end
  end

end
