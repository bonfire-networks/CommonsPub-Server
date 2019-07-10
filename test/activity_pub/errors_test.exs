# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.BuildErrorTest do
  use ExUnit.Case, async: true

  alias ActivityPub.BuildError

  @error %BuildError{
    path: ["object", "email"],
    value: "example.com",
    message: "not a valid email format",
  }

  test "key" do
    assert BuildError.key(@error) == "object.email"
  end

  test "message" do
    assert BuildError.message(@error) =~ BuildError.key(@error)
    assert BuildError.message(@error) =~ @error.value
    assert BuildError.message(@error) =~ @error.message
  end
end
