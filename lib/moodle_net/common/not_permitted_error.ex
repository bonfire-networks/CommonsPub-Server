# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.NotPermittedError do
  @enforce_keys [:message, :code, :status]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
    message: binary,
    code: binary,
    status: integer,
  }

  @doc "Create a new NotPermittedError"
  @spec new(verb :: binary) :: t
  def new(verb) when is_binary(verb) do
    %__MODULE__{
      message: "You do not have permission to #{verb} this.",
      code: "unauthorized",
      status: 403,
    }
  end

end
