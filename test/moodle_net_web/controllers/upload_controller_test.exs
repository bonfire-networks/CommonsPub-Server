# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.UploadControllerTest do
  use MoodleNetWeb.ConnCase, async: true

  alias MoodleNetWeb.Uploader
  alias MoodleNetWeb.Uploader.{Avatar, Background}

  @img_path "test/fixtures/images/150.png"

  test "fetches a upload that exists", %{conn: conn} do
    assert {:ok, uploads} = Uploader.store(Avatar, %{path: @img_path, filename: "150.png"}, 720)
    assert conn |> get(uploads.full.url) |> response(200)
    assert conn |> get(uploads.thumbnail.url) |> response(200)
  end

  test "returns 404 when file is missing", %{conn: conn} do
    assert conn
    |> get("#{MoodleNetWeb.base_url()}/uploads/missing.png")
    |> response(404)
  end
end
