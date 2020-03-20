# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.FileTest do
  use ExUnit.Case, async: true

  alias MoodleNet.File

  describe "has_extension?/2" do
    @extensions ~w(jpg jpeg png)

    test "returns true with a valid extension" do
      paths = [
        "/some/path.jpg",
        "/some/path.jpeg",
        "/some/path.png",
      ]

      for path <- paths do
        assert File.has_extension?(path, @extensions),
          "Expected file to have a valid extension: #{path}"
      end
    end

    test "returns false with an invalid extension" do
      paths = [
        "/dir/some_file.exe",
        "/dir/no_extension",
      ]

      for path <- paths do
        refute File.has_extension?(path, @extensions),
          "Expected file to have an invalid extension: #{path}"
      end
    end
  end

  describe "extension/1" do
    test "returns the file extension for a path" do
      valid_paths = %{
        "/home/someone/test.png" => ".png",
        "./some_dir/myapp.exe"   => ".exe"
      }

      for {filepath, expected} <- Map.to_list(valid_paths) do
        assert File.extension(filepath) == expected
      end
    end

    test "returns extensions in lowercase" do
      assert File.extension("/some/path/file.PNG") == ".png"
    end

    test "returns an empty string when a file has no extension" do
      assert File.extension("/some/path/file") == ""
    end
  end

  describe "basename/1" do
    test "returns the base name of a full file path" do
      assert File.basename("/some/path/file.txt") == "file"
    end

    test "returns directory name if only given a directory" do
      assert File.basename("/some/path/") == "path"
    end
  end
end
