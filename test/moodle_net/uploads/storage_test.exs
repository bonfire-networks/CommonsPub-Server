# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.StorageTest do
  use ExUnit.Case, async: true

  alias MoodleNet.Uploads.Storage

  @image_path "test/fixtures/images/150.png"

  defmodule DummyUploader do
    use MoodleNet.Uploads.Definition

    def allowed_extensions, do: :all
    def transform(_), do: :skip
  end

  describe "store" do
    test "stores a file using a path" do
      assert {:ok, file_info} = Storage.store(DummyUploader, @image_path)
      assert file_info.id
      assert file_info.media_type == "image/png"
      assert file_info.info.size
      assert file_info.metadata.width_px
      assert file_info.metadata.height_px
    end

    test "stores a file using a plug upload" do
      assert {:ok, file_info} = Storage.store(DummyUploader, %{path: @image_path, filename: "150.png"})
    end

    test "fails to store a missing file" do
      assert {:error, :enoent} = Storage.store(DummyUploader, "missing.png")
    end
  end

  describe "remote_url" do
    test "returns a valid URL for an existing identifier" do
      assert {:ok, %{id: file_id}} = Storage.store(DummyUploader, @image_path)
      assert {:ok, url} = Storage.remote_url(file_id)

      assert uri = URI.parse(url)
      assert uri.scheme
      assert uri.host
    end

    test "fails if the identifier does not exist" do
      assert {:error, :enoent} = Storage.remote_url("missing.pdf")
    end
  end

  describe "delete" do
    test "removes a file from storage if it exists" do
      assert {:ok, %{id: file_id}} = Storage.store(DummyUploader, @image_path)
      assert :ok = Storage.delete(file_id)
    end

    test "fails if the file does not exist" do
      assert {:error, :enoent} = Storage.delete("missing.png")
    end
  end
end
