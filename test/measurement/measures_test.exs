# # MoodleNet: Connecting and empowering educators worldwide
# # Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# # SPDX-License-Identifier: AGPL-3.0-only
defmodule Measurement.MeasuresTest do
  use MoodleNetWeb.ConnCase, async: true

  import MoodleNet.Test.Trendy
  import MoodleNet.Test.Faking
  import MoodleNetWeb.Test.Orderings
  import MoodleNetWeb.Test.Automaton
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNet.Common.Enums
  import Grumble
  import Zest
  alias MoodleNet.Test.Fake

  import Measurement.Test.Faking
  alias Measurement.Measure
  alias Measurement.Measure.Measures

  describe "one" do
    test "fetches an existing measure" do
      user = fake_user!()
      measure = fake_measure!(user)

      assert {:ok, fetched} = Measures.one(id: measure.id)
      assert_measure(measure, fetched)
      assert {:ok, fetched} = Measures.one(user: user)
      assert_measure(measure, fetched)
    end
  end

  describe "create" do
    test "creates a new measure" do
      user = fake_user!()
      assert {:ok, measure} = Measures.create(user, measure())
      assert_measure(measure)
    end

    test "creates a new measure with a unit" do
      # TODO
      user = fake_user!()
      unit = fake_unit!(user)
      assert {:ok, measure} = Measures.create(user, unit, measure())
      assert_measure(measure)
    end

    test "fails when missing attributes" do
      user = fake_user!()
      assert {:error, %Ecto.Changeset{}} = Measures.create(user, %{})
    end
  end

  describe "update" do
    test "updates an existing measure with new content" do
      user = fake_user!()
      measure = fake_measure!(user)

      attrs = measure()
      assert {:ok, updated} = Measures.update(measure, attrs)
      assert_measure(updated)
      assert measure != updated
    end
  end
end
