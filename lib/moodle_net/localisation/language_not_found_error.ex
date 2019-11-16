# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Localisation.LanguageNotFoundError do
  @enforce_keys [:message, :code, :status]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
    message: binary,
    code: binary,
    status: integer,
  }

  @doc "Create a new LanguageNotFoundError with the given iso code"
  @spec new() :: t
  def new() do
    %__MODULE__{
      message: "Language not found",
      code: "language_not_found",
      status: 404,
    }
  end

end
