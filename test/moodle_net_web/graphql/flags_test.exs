# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.FlagsTest do
  use MoodleNetWeb.ConnCase, async: true
  alias MoodleNet.Flags
  # import MoodleNet.MediaProxy.URLBuilder, only: [encode: 1]
  import MoodleNet.Test.Faking
  import MoodleNetWeb.Test.ConnHelpers
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields

  describe "flag" do

    test "is nil for a guest" do
      alice = fake_user!()
      bob = fake_user!()
      # alice flags bob. bob is bad.
      {:ok, flag} = Flags.create(alice, bob, %{is_local: true, message: "bad"})
      q = """
      { flag(flagId: "#{flag.id}") {
          #{flag_basics()}
        }
      }
      """
      assert %{"flag" => nil} = gql_post_data(%{query: q})
    end
  end

  describe "flag.creator" do
    # test "works for a user" do
    #   alice = fake_user!()
    #   bob = fake_user!()
    #   # alice flags bob. bob is bad.
    #   {:ok, flag} = Flags.create(alice, bob, %{is_local: true, message: "bad"})
    #   q = """
    #   { flag(flagId: "#{flag.id}") {
    #       #{flag_basics()}
    #       creator { #{user_basics()} }
    #     }
    #   }
    #   """
    #   assert %{"flag" => flag2} = gql_post_data(%{query: q})
    #   flag2 = assert_flag(flag, flag2)
    #   assert %{"creator" => creator} = flag2
    #   assert_user(alice, creator)
    # end
  end
  describe "flag.context" do
    test "nil for a guest on a user" do
      alice = fake_user!()
      bob = fake_user!()
      # alice flags bob. bob is bad.
      {:ok, flag} = Flags.create(alice, bob, %{is_local: true, message: "bad"})
      q = """
      { flag(flagId: "#{flag.id}") {
          #{flag_basics()}
          context { ... on User { #{user_basics()} } }
        }
      }
      """
      assert %{"flag" => nil} = gql_post_data(%{query: q})
    end
    test "nil for guest on a community" do
      alice = fake_user!()
      bob = fake_community!(alice)
      # alice flags bob. bob is bad.
      {:ok, flag} = Flags.create(alice, bob, %{is_local: true, message: "bad"})
      q = """
      { flag(flagId: "#{flag.id}") {
          #{flag_basics()}
          context { ... on Community { #{community_basics()} } }
        }
      }
      """
      assert %{"flag" => nil} = gql_post_data(%{query: q})
    end
    test "nil for guest on a collection" do
      alice = fake_user!()
      bob = fake_community!(alice)
      eve = fake_collection!(alice, bob)
      # alice flags bob. bob is bad.
      {:ok, flag} = Flags.create(alice, eve, %{is_local: true, message: "bad"})
      q = """
      { flag(flagId: "#{flag.id}") {
          #{flag_basics()}
          context { ... on Collection { #{collection_basics()} } }
        }
      }
      """
      assert %{"flag" => nil} = gql_post_data(%{query: q})
    end
  end

  # defp assert_already_flagged(errs, path) do
  #   assert [err] = errs
  #   assert %{"code" => code, "message" => message} = err
  #   assert %{"path" => ^path, "locations" => [loc]} = err
  #   assert code == "already_flagged"
  #   assert message == "already flagged"
  #   assert_location(loc)
  # end

end
