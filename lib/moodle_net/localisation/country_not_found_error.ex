# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Localisation.CountryNotFoundError do
  @enforce_keys [:message, :code, :status]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
    message: binary,
    code: binary,
    status: integer,
  }

  @spec new() :: t
  @doc "Create a new CountryNotFoundError"
  def new() do
    %__MODULE__{
      message: "Country not found",
      code: "country_not_found",
      status: 404,
    }
  end
end
