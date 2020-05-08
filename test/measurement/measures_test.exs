# # MoodleNet: Connecting and empowering educators worldwide
# # Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# # SPDX-License-Identifier: AGPL-3.0-only
defmodule Measurement.MeasuresTest do
  use MoodleNetWeb.ConnCase, async: true

  import MoodleNet.Test.Trendy
  import MoodleNet.Test.Faking
  import MoodleNetWeb.Test.Orderings
  import MoodleNetWeb.Test.Automaton
  import MoodleNet.Common.Enums
  import Grumble
  import Zest
  alias MoodleNet.Test.Fake

  import Measurement.Test.Faking
  alias Measurement.Measure
  alias Measurement.Measure.Measures

  describe "one" do
    
  end

  describe "create" do
    test "creates a new measure" do
      user = fake_user!()
      {:ok, measure} = Measures.create(user, %{has_numerical_value: 15})
    end
  end

  describe "update" do
    
  end
end
