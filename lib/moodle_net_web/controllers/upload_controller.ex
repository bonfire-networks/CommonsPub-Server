# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.UploadController do
  use MoodleNetWeb, :controller

  def get(conn, %{"path" => path_parts}) do
    with {:ok, path} <- MoodleNetWeb.Uploader.fetch_relative(path_parts) do
      conn
      # |> put_resp_content_type(file.content_type)
      |> send_file(200, path)
    end
  end
end
