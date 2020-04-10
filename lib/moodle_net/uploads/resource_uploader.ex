# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.ResourceUploader do
  use MoodleNet.Uploads.Definition

  def allowed_media_types,
    do: ~w(application/html application/pdf application/zip) ++
      ~w(image/png image/jpg image/svg image/gif) ++
      ~w(audio/mp3 audio/m4a audio/wav audio/flac audio/ogg) ++
      ~w(video/avi video/webm video/mp4)


  # TODO: use media types
  def allowed_extensions,
    do: ~w(rtf docx doc odt ott xls xlsx ods ots csv ppt pps pptx odp otp) ++
      ~w(odg otg odc flv eps tex mbz epub mobi torrent)

  def transform(_file), do: :skip
end
