# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.ExtensionDenied do
  @enforce_keys [:message, :code, :status]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
    message: binary,
    code: binary,
    status: integer,
  }

  def new(extension) when is_binary(extension) do
    %__MODULE__{
      message: "Files with the format of #{extension} are not allowed",
      code: "extension_denied",
      status: 415,
    }
  end
end
