# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.UploadControllerTest do
  use MoodleNetWeb.ConnCase, async: true
  import MoodleNet.Test.Faking
  alias MoodleNet.Uploads
  alias MoodleNet.Uploads.{Avatar, Background, Storage}

  @img_path "test/fixtures/images/150.png"

  @tag :skip
  test "fetches a upload that exists" do
    alice = fake_user!()
    conn = html_conn()
    upload_def = %{allowed_extensions: :all}
    upload = %{path: @img_path, filename: "150.png"}
    assert {:ok, uploads} =
      Uploads.upload(upload_def, alice, alice, %{path: @img_path, filename: "150.png"},%{})
    assert conn |> get(uploads.full.url) |> response(200)
    assert conn |> get(uploads.thumbnail.url) |> response(200)
  end

  @tag :skip
  test "returns 404 when file is missing" do
    assert html_conn()
    |> get("#{MoodleNetWeb.base_url()}/uploads/missing.png")
    |> response(404)
  end
end
