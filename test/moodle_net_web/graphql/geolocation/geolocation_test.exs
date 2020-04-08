# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Geolocation.Tests do
    # @tag :skip
    use MoodleNetWeb.ConnCase, async: true
    import MoodleNetWeb.Test.GraphQLAssertions
    import MoodleNetWeb.Test.GraphQLFields
    import MoodleNet.Test.Trendy
    import MoodleNet.Test.Faking
    import ValueFlows.Simulate
#     # alias MoodleNet.{Flags, Follows, Likes}

    describe "geolocation" do
      test "works for the owner, randoms, admins and guests" do
        [alice, bob] = some_fake_users!(%{}, 2)
        # lucy = fake_user!(%{is_instance_admin: true})
        comm = fake_community!(alice)
        item = ValueFlows.Simulate.geolocation!(alice, comm)
        conns = [user_conn(alice), user_conn(bob), user_conn(lucy), json_conn()]
        vars = %{"geolocationId" => item.id}
        for conn <- conns do
          coll2 = gruff_post_key(geolocation_query(), conn, "geolocation", vars)
          assert_geolocation(item, coll2)
        end
      end
    end
end
