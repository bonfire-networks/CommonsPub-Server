# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.Definition do
  alias MoodleNet.Uploads.Storage

  @callback valid?(Storage.file_source()) :: boolean
  @callback transform(Storage.file_source()) :: {command :: atom, arguments :: [binary]} | :skip

  defmacro __using__(opts) do
    quote do
      @behaviour __MODULE__
    end
  end
end
