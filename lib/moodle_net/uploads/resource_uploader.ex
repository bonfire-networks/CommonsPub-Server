# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.ResourceUploader do
  use MoodleNet.Uploads.Definition

  # TODO: move to config
  def allowed_media_types,
    do: ~w(text/plain text/html text/rtf text/csv) ++
      # App formats
      ~w(application/rtf application/pdf application/zip) ++
      ~w(application/x-bittorrent application/x-tex) ++
      # Docs
      ~w(application/epub+zip application/vnd.amazon.mobi8-ebook) ++
      ~w(application/postscript application/msword) ++
      ~w(application/powerpoint application/mspowerpoint application/vnd.ms-powerpoint application/x-mspowerpoint) ++
      ~w(application/excel application/x-excel application/vnd.ms-excel) ++
      ~w(application/vnd.oasis.opendocument.chart application/vnd.oasis.opendocument.formula) ++
      ~w(application/vnd.oasis.opendocument.graphics application/vnd.oasis.opendocument.image) ++
      ~w(application/vnd.oasis.opendocument.presentation application/vnd.oasis.opendocument.spreadsheet) ++
      ~w(application/vnd.oasis.opendocument.text) ++
      # Images
      ~w(image/png image/jpeg image/svg+xml image/gif) ++
      # Audio
      ~w(audio/mp3 audio/m4a audio/wav audio/flac audio/ogg) ++
      # Video
      ~w(video/avi video/webm video/mp4)


  def transform(_file), do: :skip
end
