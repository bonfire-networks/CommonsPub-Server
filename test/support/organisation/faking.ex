# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Circle.Test.Faking do
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  alias MoodleNet.Test.Fake
  alias Circle
  alias Circle.Circles

  def circle(base \\ %{}) do
    base
    |> Map.put_new_lazy(:name, &Fake.name/0)
    |> Map.put_new_lazy(:summary, &Fake.summary/0)
    |> Map.put_new_lazy(:preferred_username, &Fake.preferred_username/0)
  end

  def fake_circle!(user, overrides \\ %{}) do
    {:ok, org} = Circles.create(user, circle(overrides))
    org
  end

  def assert_circle(%Circle{} = org) do
    assert_circle(Map.from_struct(org))
  end

  def assert_circle(org) do
    assert_object org, :assert_circle,
      [id: &assert_ulid/1,
      #  character.name: &assert_binary/1,
      #  character.updated_at: assert_optional(&assert_datetime/1),
      #  disabled_at: assert_optional(&assert_datetime/1),
      ]
  end

  def circle_fields(extra \\ []) do
    extra ++ ~w(id name summary __typename)a
  end

  def circle_query(options \\ []) do
    gen_query(:circle_id, &circle_subquery/1, options)
  end

  def circle_subquery(options \\ []) do
    gen_subquery(:circle_id, :circle, &circle_fields/1, options)
  end
end
