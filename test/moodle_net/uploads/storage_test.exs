# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.StorageTest do
  use ExUnit.Case, async: true

  alias MoodleNet.Uploads.Storage

  describe "store" do
    test "stores a file using a path" do
      assert {:ok, file_info} = Storage.store("test/fixtures/images/150.png")
    end

    test "stores a file using a plug upload" do
      assert {:ok, file_info} =
               Storage.store(%{path: "test/fixtures/images/150.png", filename: "150.png"})
    end

    test "fails to store a missing file" do
      assert {:error, :enoent} = Storage.store("missing.png")
    end

    test "fails to store a file with a blocked extension" do
    end
  end

  describe "remote_url" do
  end

  describe "delete" do
  end
end
