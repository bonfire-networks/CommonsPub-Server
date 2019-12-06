# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.ResourceUploader do
  use MoodleNet.Uploads.Definition

  def allowed_extensions, do: ~w(pdf rtf ogg mp3 flac wav flv gif jpg jpeg png)

  def transform(file) do
    :skip
  end
end
