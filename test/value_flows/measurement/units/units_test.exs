# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Measurement.Units.UnitsTest do
  # @tag :skip
  use MoodleNetWeb.ConnCase, async: true
  import MoodleNetWeb.Test.Automaton

  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import MoodleNet.Test.Trendy
  import MoodleNet.Test.Faking
  import MoodleNetWeb.Test.Orderings
  import MoodleNetWeb.Test.Automaton
  import MoodleNet.Common.Enums
  import Grumble
  import Zest

  import Measurement.Units.Faking 

  describe "units" do

    test "works for a guest" do
      users = some_fake_users!(3)
      communities = some_fake_communities!(3, users) # 9
      units = some_fake_collections!(1, users, communities) # 27
      root_page_test %{
        query: units_query(),
        connection: json_conn(),
        return_key: :units,
        default_limit: 10,
        total_count: 27,
        data: order_follower_count(units),
        assert_fn: &assert_unit/2,
        cursor_fn: &[&1.id],
        after: :collections_after,
        before: :collections_before,
        limit: :collections_limit,
      }
    end

  end



end
