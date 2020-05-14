# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Organisation.Test.Faking do
  import MoodleNetWeb.Test.GraphQLAssertions
  alias MoodleNet.Test.Fake
  alias Organisation
  alias Organisation.Organisations

  def organisation(base \\ %{}) do
    base
    |> Map.put_new_lazy(:name, &Fake.name/0)
    |> Map.put_new_lazy(:summary, &Fake.summary/0)
    |> Map.put_new_lazy(:preferred_username, &Fake.preferred_username/0)
  end

  def fake_organisation!(user, overrides \\ %{}) do
    {:ok, org} = Organisations.create(user, organisation(overrides))
    org
  end

  def assert_organisation(%Organisation{} = org) do
    assert_organisation(Map.from_struct(org))
  end

  def assert_organisation(org) do
    assert_object org, :assert_organisation,
      [id: &assert_ulid/1,
       summary: &assert_binary/1,
       published_at: assert_optional(&assert_datetime/1),
       disabled_at: assert_optional(&assert_datetime/1),
      ]
  end
end
