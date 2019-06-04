# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.IRITest do
  use ExUnit.Case, async: true

  alias ActivityPub.IRI

  test "validate" do
    assert IRI.validate(nil) == {:error, :not_string}

    assert IRI.validate("social.example") == {:error, :invalid_scheme}

    assert IRI.validate("https://") == {:error, :invalid_host}

    assert IRI.validate("https://social.example/") == :ok

    assert IRI.validate("https://social.example/alyssa") == :ok
  end
end
