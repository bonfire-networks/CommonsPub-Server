# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.ImageUploader do
  use MoodleNet.Uploads.Definition

  def allowed_extensions, do: ~w(gif jpg jpeg png)

  def transform(_file), do: :skip
end
