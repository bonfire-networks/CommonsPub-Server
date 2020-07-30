# Based on code from MoodleNet
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Simulate do
  @moduledoc false

  import CommonsPub.Utils.Simulation
  import CommonsPub.Utils.Trendy

  alias Geolocation.Geolocations
  alias Measurement.Simulate

  @doc "A unit"
  def unit_name(), do: Faker.Util.pick(["kilo", "liter"])
  def unit_symbol(), do: Faker.Util.pick(["kg", "m"])

  def agent_type(), do: Faker.Util.pick([:person, :organization])

  ### Start fake data functions

  ## ValueFlows

  def unit(base \\ %{}) do
    base
    # todo: these can't both be right
    |> Map.put_new_lazy(:id, &uuid/0)
    |> Map.put_new_lazy(:label, &unit_name/0)
    |> Map.put_new_lazy(:symbol, &unit_symbol/0)
  end

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

  # utils

  def short_count(), do: Faker.random_between(0, 3)
  def med_count(), do: Faker.random_between(3, 9)
  def long_count(), do: Faker.random_between(10, 25)
  def short_list(gen), do: Faker.Util.list(short_count(), gen)
  def med_list(gen), do: Faker.Util.list(med_count(), gen)
  def long_list(gen), do: Faker.Util.list(long_count(), gen)
  def one_of(gens), do: Faker.Util.pick(gens).()

  def page_info(base \\ %{}) do
    base
    |> Map.put_new_lazy(:start_cursor, &uuid/0)
    |> Map.put_new_lazy(:end_cursor, &uuid/0)
    |> Map.put(:__struct__, MoodleNet.GraphQL.PageInfo)
  end

  def long_node_list(base \\ %{}, gen) do
    base
    |> Map.put_new_lazy(:page_info, &page_info/0)
    |> Map.put_new_lazy(:total_count, &pos_integer/0)
    |> Map.put_new_lazy(:nodes, fn -> long_list(gen) end)
    |> Map.put(:__struct__, MoodleNet.GraphQL.NodeList)
  end

  def long_edge_list(base \\ %{}, gen) do
    base
    |> Map.put_new_lazy(:page_info, &page_info/0)
    |> Map.put_new_lazy(:total_count, &pos_integer/0)
    |> Map.put_new_lazy(:edges, fn -> long_list(fn -> edge(gen) end) end)
    |> Map.put(:__struct__, MoodleNet.GraphQL.EdgeList)
  end

  def edge(base \\ %{}, gen) do
    base
    |> Map.put_new_lazy(:cursor, &uuid/0)
    |> Map.put_new_lazy(:node, gen)
    |> Map.put(:__struct__, MoodleNet.GraphQL.Edge)
  end
end
