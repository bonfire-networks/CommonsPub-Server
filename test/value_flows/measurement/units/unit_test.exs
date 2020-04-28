# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Measurement.Units.UnitTest do
  # @tag :skip
  use MoodleNetWeb.ConnCase, async: true
  import MoodleNetWeb.Test.Automaton

  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import MoodleNet.Test.Trendy
  import MoodleNet.Test.Faking
  import Grumble
  import Zest

  import Measurement.Unit.Faking


  describe "unit" do

    @tag :skip
    test "works for the owner, randoms, admins and guests" do
      [alice, bob] = some_fake_users!(%{}, 2)
      comm = fake_community!(alice)
      item = unit!(alice, comm)
      conns = [user_conn(alice), user_conn(bob), json_conn()]
      vars = %{id: item.id}
      for conn <- conns do
        unit2 = grumble_post_key(unit_query(), conn, :unit, vars)
        assert_unit(unit2)
      end
    end

  end
end
