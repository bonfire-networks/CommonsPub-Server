# Based on code from MoodleNet
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Geolocation.Faking do
  @moduledoc false

  alias MoodleNet.Test.Fake
  alias Geolocation.Geolocations

  @doc "A unit"
  def unit_name(), do: Faker.Util.pick(["kilo", "liter"])
  def unit_symbol(), do: Faker.Util.pick(["kg", "m"])


  ### Start fake data functions

  ## Geolocation

  def geolocation(base \\ %{}) do
    base
    |> Map.put_new_lazy(:name, &Fake.name/0)
    |> Map.put_new_lazy(:note, &Fake.summary/0)
    # |> Map.put_new_lazy(:icon, &Fake.icon/0)
    |> Map.put_new_lazy(:is_public, &Fake.truth/0)
    |> Map.put_new_lazy(:is_disabled, &Fake.falsehood/0)
    |> Map.put_new_lazy(:is_featured, &Fake.falsehood/0)
    |> Map.merge(Fake.actor(base))
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
    |> Map.put_new_lazy(:start_cursor, &Fake.uuid/0)
    |> Map.put_new_lazy(:end_cursor, &Fake.uuid/0)
    |> Map.put(:__struct__, MoodleNet.GraphQL.PageInfo)
  end

  def long_node_list(base \\ %{}, gen) do
    base
    |> Map.put_new_lazy(:page_info, &page_info/0)
    |> Map.put_new_lazy(:total_count, &Fake.pos_integer/0)
    |> Map.put_new_lazy(:nodes, fn -> long_list(gen) end)
    |> Map.put(:__struct__, MoodleNet.GraphQL.NodeList)
  end

  def long_edge_list(base \\ %{}, gen) do
    base
    |> Map.put_new_lazy(:page_info, &page_info/0)
    |> Map.put_new_lazy(:total_count, &Fake.pos_integer/0)
    |> Map.put_new_lazy(:edges, fn -> long_list(fn -> edge(gen) end) end)
    |> Map.put(:__struct__, MoodleNet.GraphQL.EdgeList)
  end

  def edge(base \\ %{}, gen) do
    base
    |> Map.put_new_lazy(:cursor, &Fake.uuid/0)
    |> Map.put_new_lazy(:node, gen)
    |> Map.put(:__struct__, MoodleNet.GraphQL.Edge)
  end


end
