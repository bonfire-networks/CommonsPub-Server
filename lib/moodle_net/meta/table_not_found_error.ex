# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Meta.TableNotFoundError do
  @enforce_keys [:table]
  defstruct @enforce_keys

  @type t :: %__MODULE__{ table: term }

  @spec new(term) :: t
  def new(table), do: %__MODULE__{table: table}
end
