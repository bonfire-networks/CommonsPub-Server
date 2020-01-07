# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Flags.AlreadyFlaggedError do
  @enforce_keys [:message, :code, :status]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
    message: binary,
    code: binary,
    status: integer,
  }

  @doc "Create a new AlreadyFlaggedError"
  @spec new(type :: binary) :: t
  def new(type) when is_binary(type) do
    %__MODULE__{
      message: "You have already flagged this #{type}",
      code: "already_flagged",
      status: 409,
    }
  end
end
