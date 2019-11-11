# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.UploadsTest do
  use MoodleNet.DataCase, async: true

  import MoodleNet.Test.Faking
  alias MoodleNet.Uploads

  describe "fetch" do
    test "returns an upload for an existing ID" do

    end

    test "fails when given a missing ID" do

    end
  end

  describe "fetch_by_path" do
    test "returns an upload with the given path" do

    end

    test "fails when the path is missing" do

    end
  end

  describe "upload" do
    test "creates a file upload" do
      actor = fake_actor!()
      language = fake_language!()
      community = fake_community!(actor, language)
      file = %{path: "test/fixtures/images/150.png", filename: "150.png"}

      assert {:ok, upload} = Uploads.upload(community, actor, file, %{is_public: true})
      assert upload.path
      assert upload.size
      assert upload.media_type == "image/png"
      assert upload.metadata.width_px
      assert upload.metadata.height_px
    end

    test "fails when the file has a disallowed extension" do
      actor = fake_actor!()
      language = fake_language!()
      community = fake_community!(actor, language)
      file = %{path: "test/fixtures/not-a-virus.exe", filename: "not-a-virus.exe"}
      assert {:error, :extension_denied} = Uploads.upload(community, actor, file, %{is_public: true})
    end

    test "fails when the upload is a missing file" do
      actor = fake_actor!()
      language = fake_language!()
      community = fake_community!(actor, language)
      file = %{path: "missing.pdf", filename: "missing.pdf"}
      assert {:error, :enoent} = Uploads.upload(community, actor, file, %{is_public: true})
    end

    test "fails when the upload is missing attributes" do
      actor = fake_actor!()
      language = fake_language!()
      community = fake_community!(actor, language)
      file = %{path: "test/fixtures/images/150.png", filename: "150.png"}
      assert {:error, changeset} = Uploads.upload(community, actor, file, %{})
      assert Keyword.get(changeset.errors, :is_public)
    end
  end

  describe "remote_url" do
    test "returns the remote URL for an existing upload" do

    end

    test "returns an error when the upload is missing" do

    end
  end

  describe "soft_delete" do
    test "updates the deletion date of the upload" do

    end
  end

  describe "hard_delete" do
    test "removes the upload, including files" do

    end
  end
end
