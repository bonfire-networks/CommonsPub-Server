# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.ImageUploader do
  use MoodleNet.Uploads.Definition

  def allowed_media_types do
    :moodle_net
    |> Application.fetch_env!(__MODULE__)
    |> Keyword.fetch!(:allowed_media_types)
  end

  def transform(_file), do: :skip
end
