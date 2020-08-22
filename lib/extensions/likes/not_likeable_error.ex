# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Likes.NotLikeableError do
  @enforce_keys [:message, :code, :status]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
    message: binary,
    code: binary,
    status: integer,
  }

  @doc "Create a new NotLikeableError"
  @spec new(type :: binary) :: t
  def new(type) when is_binary(type) do
    %__MODULE__{
      message: "You can not like a #{type}",
      code: "not_likeable",
      status: 403,
    }
  end

end
