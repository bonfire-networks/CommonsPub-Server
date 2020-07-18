# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Circle.GraphQLTest do
  use MoodleNetWeb.ConnCase, async: true
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import MoodleNet.Test.Faking

  import Circle.Test.Faking

  describe "circle" do
    test "works for a logged in user" do
      alice = fake_user!()
      org = fake_circle!(alice)

      vars = %{circle_id: org.id}
      conn = user_conn(alice)
      q = circle_query()

      assert_circle(grumble_post_key(q, conn, :circle, vars))
    end

    test "can be created with a context" do

    end

    test "does not work for a guest" do

    end
  end

  describe "circle.icon" do
  end

  describe "circle.creator" do

  end

  describe "circle.context" do
  end
end
