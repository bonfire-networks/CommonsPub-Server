# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.BuildError do
  @moduledoc """
  Indicates an entity could not be parsed due to invalid data.
  """

  @type t :: %__MODULE__{
          path: [String.t()],
          value: String.t(),
          message: String.t(),
          additional_info: Keyword.t()
        }

  @enforce_keys [:path, :value, :message]
  defexception [:path, :value, :message, additional_info: []]

  def message(%__MODULE__{} = e),
    do: "The field #{key(e)} with value #{inspect(e.value)} could not be parsed: #{e.message}"

  def key(%__MODULE__{path: path}), do: Enum.join(path, ".")
end
