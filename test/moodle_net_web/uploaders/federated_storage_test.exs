# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.Uploaders.FederatedStorageTest do
  use ExUnit.Case, async: true

  alias MoodleNetWeb.Uploaders.FederatedStorage

  @storage_dir "test/test-uploads"
  @img_path "test/fixtures/images/150.png"

  setup_all do
    File.mkdir_p!(@storage_dir)

    on_exit fn ->
      File.rm_rf!(@storage_dir)
    end
  end

  def assert_valid_url(url) do
    uri = URI.parse(url)
    assert uri.scheme
    assert uri.host
    assert uri.path
  end

  defmodule DummyDefinition do
    use Arc.Definition

    def transform(:thumbnail, _), do: {:convert, "-strip -thumbnail 10x10"}
    def transform(:original, _), do: :noaction
    def __versions, do: [:original, :thumbnail]
    # TODO: use parent @storage_dir
    def storage_dir(_, _), do: "test/test-uploads"
    def __storage, do: FederatedStorage
    def filename(:original, {file, _}),
      do: "original-#{MoodleNet.File.basename(file.file_name)}"
    def filename(:thumbnail, {file, _}),
      do: "1/thumb-#{MoodleNet.File.basename(file.file_name)}"
  end

  describe "put" do
    test "handles binary files" do
      file = Arc.File.new(%{filename: "binary.png", binary: "binary"})
      assert {:ok, url} = FederatedStorage.put(DummyDefinition, :original, {file, nil})
      assert File.exists?("#{@storage_dir}/original-#{file.file_name}")
    end

    test "handles filesystem files" do
      file = Arc.File.new(%{filename: "image.png", path: @img_path})

      assert {:ok, url} = FederatedStorage.put(DummyDefinition, :original, {file, nil})
      assert url =~ file.file_name
      assert File.exists?("#{@storage_dir}/original-#{file.file_name}")

      assert {:ok, url} = FederatedStorage.put(DummyDefinition, :thumbnail, {file, nil})
      assert url =~ "1/thumb-#{file.file_name}"
      assert File.exists?("#{@storage_dir}/1/thumb-#{file.file_name}")
    end

    test "returns a fully formed URL" do
      file = Arc.File.new(%{filename: "image.png", binary: "binary"})
      assert {:ok, url} = FederatedStorage.put(DummyDefinition, :original, {file, nil})
      assert_valid_url url
    end
  end

  describe "url" do
    test "returns a full URL given a file" do
      file = Arc.File.new(%{filename: "image.png", binary: "binary"})
      url = FederatedStorage.url(DummyDefinition, :original, {file, nil})
      assert_valid_url url
      assert url =~ "original-#{file.file_name}"
    end
  end

  describe "delete" do
    test "removes a file from the filesystem" do
      file = Arc.File.new(%{filename: "delete-me.jpg", binary: "jpegs amirite?"})
      assert {:ok, _} = FederatedStorage.put(DummyDefinition, :original, {file, nil})
      assert :ok = FederatedStorage.delete(DummyDefinition, :original, {file, nil})
      refute File.exists?("#{@storage_dir}/original-delete-me.jpg")
    end
  end
end

