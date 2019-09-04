# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/>, CommonsPub <https://commonspub.org/> and Arc <https://github.com/stavro/arc>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.UploaderTest do
  use ExUnit.Case, async: true

  alias MoodleNetWeb.Uploader

  @img_path "test/fixtures/images/150.png"

  defmodule DummyDefinition do
    use MoodleNetWeb.Uploader.Definition

    def versions, do: [:full]
    def valid?(_file, _), do: true
    def filename(_, file, nil), do: "#{file.filename}"
    def filename(_, file, id) when is_integer(id), do: "#{id}/#{file.filename}"
    def transform(_, _, _), do: :skip
  end

  describe "store/3" do
    test "stores a valid file and returns uploads" do
      assert {:ok, %{full: upload}} = Uploader.store(DummyDefinition, %{path: @img_path, filename: "150.png"})
      assert upload.url =~ Uploader.storage_dir()
      assert upload.url =~ "150.png"
      assert upload.media_type == "image/png"
      assert upload.metadata.height_px == 150
      assert upload.metadata.width_px == 150
    end
  end

  describe "fetch_relative/1" do
    test "returns a path if the URL is correct" do
      file = %{path: @img_path, filename: "150.png"}
      assert {:ok, %{full: upload}} = Uploader.store(DummyDefinition, file)
      assert {:ok, path} = Uploader.fetch_relative(file.filename)
      assert path == Path.join([Uploader.storage_dir(), "150.png"])
    end

    test "returns :not_found if the file is missing" do
      file = %{path: "missing.png", filename: "missing.png"}
      assert {:error, :not_found} = Uploader.store(DummyDefinition, file)
    end
  end
end
