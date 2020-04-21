# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.AdminTest do
  use MoodleNetWeb.ConnCase

  import MoodleNet.Test.Faking
  alias MoodleNet.Test.Fake
  import MoodleNetWeb.Test.GraphQLFields
  import Grumble

  describe "invites" do
    test "sends an invite" do
      user = fake_admin!()
      conn = user_conn(user)
      q = invite_mutation()

      assert true == grumble_post_key(q, conn, :send_invite, %{email: Fake.email()})
    end

    test "fails if user is not an admin" do
      user = fake_user!()
      conn = user_conn(user)
      q = invite_mutation()

      assert [
               %{
                 "code" => "unauthorized",
                 "locations" => [%{"column" => 3, "line" => 2}],
                 "message" => "You do not have permission to do this.",
                 "path" => ["sendInvite"],
                 "status" => 403
               }
             ] = grumble_post_errors(q, conn, %{email: Fake.email()})
    end
  end
end
