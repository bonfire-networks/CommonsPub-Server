# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.InstanceTest do
  use MoodleNetWeb.ConnCase, async: true
  alias MoodleNet.Test.Fake
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import MoodleNet.Test.Faking
  alias MoodleNet.{Access, Users}

  describe "instance" do
    @tag :skip
    test "placeholder" do
    end
  end

  describe "instance.outbox" do
    @tag :skip
    test "placeholder" do
    end
  end

end
