# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.Geolocation.GeolocationTest do
    # @tag :skip
    use MoodleNetWeb.ConnCase, async: true
    import MoodleNetWeb.Test.Automaton

    import MoodleNetWeb.Test.GraphQLAssertions
    import MoodleNetWeb.Test.GraphQLFields
    import MoodleNet.Test.Trendy
    import MoodleNet.Test.Faking
    import Grumble
    import Zest

    import Geolocation.Faking
    import Geolocation.Testing
#     # alias MoodleNet.{Flags, Follows, Likes}


    describe "geolocation" do
      test "works for the owner, randoms, admins and guests" do
        [alice, bob] = some_fake_users!(%{}, 2)
        comm = fake_community!(alice)
        item = geolocation!(alice, comm)
        conns = [user_conn(alice), user_conn(bob), json_conn()]
        vars = %{id: item.id}
        for conn <- conns do
          geo2 = grumble_post_key(geolocation_query(), conn, :spatial_thing, vars)
          assert_geolocation(geo2)
        end
      end
    end
end
