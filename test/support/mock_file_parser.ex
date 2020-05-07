# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.MockFileParser do
  def from_uri(uri) do
    {:ok, %{media_type: ext_media_type(Path.extname(uri))}}
  end

  def ext_media_type(".jpg"), do: "image/jpeg"
  def ext_media_type(".jpeg"), do: "image/jpeg"
  def ext_media_type(".gif"), do: "image/gif"
  def ext_media_type(_), do: "image/png"
end
