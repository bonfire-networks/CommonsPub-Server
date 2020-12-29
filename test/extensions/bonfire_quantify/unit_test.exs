# # SPDX-License-Identifier: AGPL-3.0-only
# defmodule Bonfire.Quantify.UnitTest do
#   # @tag :skip
#   use CommonsPub.Web.ConnCase, async: true
#   import CommonsPub.Web.Test.Automaton

#   import Bonfire.GraphQL.Test.GraphQLAssertions
#   import Bonfire.GraphQL.Test.GraphQLFields
#   import CommonsPub.Utils.Trendy
#   import Bonfire.Common.Simulation
  import CommonsPub.Utils.Simulate
#   import Grumble
#   import Zest

#   import Bonfire.Quantify.Test.Faking

#   describe "unit" do

#     @tag :skip
#     test "works for the owner, randoms, admins and guests" do
#       [alice, bob] = some_fake_users!(%{}, 2)
#       comm = fake_community!(alice)
#       item = unit!(alice, comm)
#       conns = [user_conn(alice), user_conn(bob), json_conn()]
#       vars = %{id: item.id}
#       for conn <- conns do
#         unit2 = grumble_post_key(unit_query(), conn, :unit, vars)
#         assert_unit(unit2)
#       end
#     end

#   end
# end
