# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.StorageTest do
  use ExUnit.Case, async: true

  alias MoodleNet.Uploads.Storage

  describe "store" do
    test "stores a file" do
      assert {:ok, file_info} = Storage.store(%{file: "test/fixtures/images/150.png"})
    end
  end

  describe "remote_url" do
    
  end

  describe "delete" do
    
  end
end
