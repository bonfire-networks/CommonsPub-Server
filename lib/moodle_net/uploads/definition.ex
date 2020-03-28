# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.Definition do
  alias MoodleNet.Uploads.Storage

  @callback allowed_extensions() :: [binary] | :all
  @callback transform(Storage.file_source()) :: {command :: atom, arguments :: [binary]} | :skip

  defmacro __using__(_opts) do
    quote do
      @behaviour MoodleNet.Uploads.Definition
    end
  end
end
