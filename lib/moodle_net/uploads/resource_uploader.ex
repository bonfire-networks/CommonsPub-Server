# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.ResourceUploader do
  use MoodleNet.Uploads.Definition

  def allowed_extensions,
    do: ~w(pdf rtf docx doc odt ott xls xlsx ods ots csv ppt pps pptx odp otp) ++
      ~w(odg otg odc ogg mp3 m4a wav mp4 flv avi gif jpg jpeg png svg webm) ++
      ~w(eps tex mbz)

  def transform(_file), do: :skip
end
