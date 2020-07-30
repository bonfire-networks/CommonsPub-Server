# Based on code from MoodleNet
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Simulate do
  @moduledoc false

  import CommonsPub.Utils.Simulation
  import CommonsPub.Utils.Trendy

  import Measurement.Simulate

  alias Geolocation.Geolocations

  def agent_type(), do: Faker.Util.pick([:person, :organization])

  ### Start fake data functions

  ## ValueFlows

  def agent(base \\ %{}) do
    base
    |> Map.put_new_lazy(:id, &uuid/0)
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:note, &summary/0)
    |> Map.put_new_lazy(:image, &image/0)
    |> Map.put_new_lazy(:agent_type, &agent_type/0)
  end

  def inc_dec(), do: Faker.Util.pick(["increment", "decrement"])

  def action(base \\ %{}) do
    base
    |> Map.put_new_lazy(:id, &uuid/0)
    |> Map.put_new_lazy(:label, &name/0)
    |> Map.put_new_lazy(:resourceEffect, &inc_dec/0)
  end

  def intent(base \\ %{}) do
    base
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:note, &summary/0)
    # |> Map.put_new_lazy(:image, &icon/0)
    |> Map.put_new_lazy(:provider, &agent/0)
    |> Map.put_new_lazy(:receiver, &agent/0)
    |> Map.put_new_lazy(:has_beginning, &past_datetime/0)
    |> Map.put_new_lazy(:has_end, &future_datetime/0)
    |> Map.put_new_lazy(:has_point_in_time, &future_datetime/0)
    |> Map.put_new_lazy(:due, &future_datetime/0)
    # TODO: list of URI's
    |> Map.put_new_lazy(:resource_classified_as, fn -> some(1..5, &url/0) end)
    |> Map.put_new_lazy(:finished, &bool/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_disabled, &falsehood/0)
  end

  def intent_input(unit, base \\ %{}) do
    base
    |> Map.put_new_lazy("name", &name/0)
    |> Map.put_new_lazy("note", &summary/0)
    # |> Map.put_new_lazy("image", &icon/0)
    |> Map.put_new_lazy("resource_classified_as", fn -> some(1..5, &url/0) end)
    # |> Map.put_new_lazy("has_beginning", &past_datetime/0)
    # |> Map.put_new_lazy("has_end", &future_datetime/0)
    # |> Map.put_new_lazy("has_point_in_time", &future_datetime/0)
    # |> Map.put_new_lazy("due", &future_datetime/0)
    |> Map.put_new_lazy("finished", &bool/0)
    |> Map.put_new_lazy("available_quantity", fn -> measure_input(unit) end)
    |> Map.put_new_lazy("resource_quantity", fn -> measure_input(unit) end)
    |> Map.put_new_lazy("effort_quantity", fn -> measure_input(unit) end)
  end

  def fake_intent!(user, unit, overrides \\ %{}) do
    measures = %{
      resource_quantity: fake_measure!(user, unit),
      effort_quantity: fake_measure!(user, unit),
      available_quantity: fake_measure!(user, unit)
    }

    {:ok, intent} = Intents.create(user, measures, intent(overrides))
    intent
  end

  def geolocation(base \\ %{}) do
    base
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:note, &summary/0)
    # |> Map.put_new_lazy(:icon, &icon/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_disabled, &falsehood/0)
    |> Map.put_new_lazy(:is_featured, &falsehood/0)
    |> Map.merge(actor(base))
  end

  def geolocation!(user, community, overrides \\ %{}) when is_map(overrides) do
    {:ok, geolocation} = Geolocations.create(user, community, geolocation(overrides))
    geolocation
  end
end
