# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Flags.NotFlaggableError do
  @enforce_keys [:message, :code, :status]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
    message: binary,
    code: binary,
    status: integer,
  }

  @doc "Create a new NotFlaggableError"
  @spec new(type :: binary) :: t
  def new(type) when is_binary(type) do
    %__MODULE__{
      message: "You can not flag a #{type}.",
      code: "not_flaggable",
      status: 403,
    }
  end

end
