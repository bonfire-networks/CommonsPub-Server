# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Mootils.Test.Bose64 do

  use ExUnit.Case
  use ExUnitProperties
  import StreamData
  alias Mootils.Bose64

  property "Preserves binary sort order" do
    check all ins <- list_of(binary()) do
      encoded = Enum.map(ins,&Bose64.encode/1)
      sorted = Enum.sort(ins)
      outs = Enum.map(Enum.sort(encoded), &Bose64.decode!/1)
      assert outs == sorted
    end
  end

end
