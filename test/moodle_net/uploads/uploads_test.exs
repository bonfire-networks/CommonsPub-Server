# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.UploadsTest do
  use MoodleNet.DataCase, async: true

  import MoodleNet.Test.Faking
  alias MoodleNet.Test.Fake
  alias MoodleNet.Uploads
  alias MoodleNet.Uploads.Storage

  @image_file %{path: "test/fixtures/images/150.png", filename: "150.png"}

  def fake_upload(file, attrs \\ %{}) do
    user = fake_user!()
    community = fake_community!(user)

    upload_def =
      Faker.Util.pick([
        MoodleNet.Uploads.IconUploader,
        MoodleNet.Uploads.ImageUploader,
        MoodleNet.Uploads.ResourceUploader
      ])

    Uploads.upload(upload_def, community, user, file, attrs)
  end

  def strip(upload), do: Map.drop(upload, [:is_public, :url])

  describe "list_by_parent" do
    test "returns a list of uploads for a parent" do
      comm = fake_user!() |> fake_community!()

      uploads =
        for _ <- 1..5 do
          user = fake_user!()

          {:ok, upload} =
            Uploads.upload(MoodleNet.Uploads.IconUploader, comm, user, @image_file, %{})

          upload
        end

      assert Enum.count(uploads) == Enum.count(Uploads.list_by_parent(comm))
    end
  end

  describe "fetch" do
    test "returns an upload for an existing ID" do
      assert {:ok, original_upload} = fake_upload(@image_file)
      assert {:ok, fetched_upload} = Uploads.fetch(original_upload.id)
      assert original_upload.id == fetched_upload.id
      assert original_upload.path == fetched_upload.path
    end

    test "fails when given a missing ID" do
      assert {:error, %MoodleNet.Common.NotFoundError{}} = Uploads.fetch(Fake.ulid())
    end
  end

  describe "fetch_by_path" do
    test "returns an upload with the given path" do
      assert {:ok, original_upload} = fake_upload(@image_file)
      assert {:ok, fetched_upload} = Uploads.fetch_by_path(original_upload.path)
      assert original_upload.id == fetched_upload.id
      assert original_upload.path == fetched_upload.path
    end

    test "fails when the path is missing" do
      assert {:error, %MoodleNet.Common.NotFoundError{}} = Uploads.fetch_by_path("missing.png")
    end
  end

  describe "upload" do
    test "creates a file upload" do
      assert {:ok, upload} = fake_upload(@image_file)
      assert upload.path
      assert upload.size
      assert upload.media_type == "image/png"
      assert upload.metadata.width_px
      assert upload.metadata.height_px
    end

    test "fails when the file has a disallowed extension" do
      file = %{path: "test/fixtures/not-a-virus.exe", filename: "not-a-virus.exe"}
      assert {:error, :extension_denied} = fake_upload(file)
    end

    test "fails when the upload is a missing file" do
      file = %{path: "missing.gif", filename: "missing.gif"}
      assert {:error, :enoent} = fake_upload(file)
    end
  end

  describe "remote_url" do
    test "returns the remote URL for an existing upload" do
      assert {:ok, upload} = fake_upload(@image_file)
      assert {:ok, url} = Uploads.remote_url(upload)

      uri = URI.parse(url)
      assert uri.scheme
      assert uri.host
      assert uri.path
    end

    test "returns an error when the upload is missing" do
      assert {:ok, upload} = fake_upload(@image_file)
      assert {:error, :enoent} = Uploads.remote_url(%{upload | path: "missing.png"})
    end
  end

  describe "soft_delete" do
    test "updates the deletion date of the upload" do
      assert {:ok, upload} = fake_upload(@image_file)
      refute upload.deleted_at
      assert {:ok, deleted_upload} = Uploads.soft_delete(upload)
      assert deleted_upload.deleted_at
      # file should still be available
      assert {:ok, _} = Storage.remote_url(upload.path)
    end
  end

  describe "hard_delete" do
    test "removes the upload, including files" do
      assert {:ok, upload} = fake_upload(@image_file)
      assert :ok = Uploads.hard_delete(upload)
      assert {:error, :enoent} = Storage.remote_url(upload.path)
    end
  end
end
