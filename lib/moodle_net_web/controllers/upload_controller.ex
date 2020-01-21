# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.UploadController do
  use MoodleNetWeb, :controller

  alias MoodleNet.Uploads

  def get(conn, %{"path" => path_parts}) do
    path = Enum.join(path_parts, "/")
    with {:ok, upload} <- Uploads.fetch_by_path(path) do
      conn
      |> put_resp_content_type(upload.media_type)
      |> send_file(200, upload.path)
    end
  end
end
