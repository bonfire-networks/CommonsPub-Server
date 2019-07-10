# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.FieldTest do
  use ExUnit.Case, async: true

  alias ActivityPub.Field

  test "build" do
    opts = [
      aspect: ActivityPub.ObjectAspect,
      name: "test",
      type: :boolean
    ]
    assert %Field{default: nil} = Field.build(opts)
    assert %Field{default: []} = Field.build(
      Keyword.put(opts, :functional, false)
    )
    assert %Field{default: true} = Field.build(
      Keyword.put(opts, :default, true)
    )
  end
end
