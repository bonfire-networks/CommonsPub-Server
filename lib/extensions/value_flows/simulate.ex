# Based on code from MoodleNet
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Simulate do
  @moduledoc false

  alias MoodleNet.Test.Fake
  alias Geolocation.Geolocations

  @doc "A unit"
  def unit_name(), do: Faker.Util.pick(["kilo", "liter"])
  def unit_symbol(), do: Faker.Util.pick(["kg", "m"])

  alias ValueFlows.Planning.Intent.Intents
  alias ValueFlows.Proposals
  alias ValueFlows.Proposal.ProposedIntent

  alias ValueFlows.Knowledge.Action.Actions

  def agent_type(), do: Faker.Util.pick([:person, :organization])

  ### Start fake data functions

  ## ValueFlows

  def unit(base \\ %{}) do
    base
    |> Map.put_new_lazy(:id, &Fake.uuid/0) # todo: these can't both be right
    |> Map.put_new_lazy(:label, &unit_name/0)
    |> Map.put_new_lazy(:symbol, &unit_symbol/0)
  end

  def agent(base \\ %{}) do
    base
    |> Map.put_new_lazy(:id, &Fake.uuid/0)
    |> Map.put_new_lazy(:name, &Fake.name/0)
    |> Map.put_new_lazy(:note, &Fake.summary/0)
    |> Map.put_new_lazy(:image, &Fake.image/0)
    |> Map.put_new_lazy(:agent_type, &agent_type/0)
  end

  def inc_dec(), do: Faker.Util.pick(["increment", "decrement"])

  def action(base \\ %{}) do
    base
    |> Map.put_new_lazy(:id, &Fake.uuid/0)
    |> Map.put_new_lazy(:label, &Fake.name/0)
    |> Map.put_new_lazy(:resourceEffect, &inc_dec/0)

  end

  def proposal(base \\ %{}) do
    base
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:note, &summary/0)
    # |> Map.put_new_lazy(:image, &icon/0)
    |> Map.put_new_lazy(:has_beginning, &past_datetime/0)
    |> Map.put_new_lazy(:has_end, &future_datetime/0)
    |> Map.put_new_lazy(:created, &future_datetime/0)
    |> Map.put_new_lazy(:unit_based, &bool/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_disabled, &falsehood/0)
  end

  def proposed_intent(base \\ %{}) do
    base
    |> Map.put_new_lazy(:reciprocal, &maybe_bool/0)
  end

  def proposed_intent_input(base \\ %{}) do
    base
    |> Map.put_new_lazy("reciprocal", &maybe_bool/0)
  end

  def intent(base \\ %{}) do
    base
    |> Map.put_new_lazy(:id, &Fake.uuid/0)
    |> Map.put_new_lazy(:name, &Fake.name/0)
    |> Map.put_new_lazy(:resource_classified_as, &Fake.website/0)
    |> Map.put_new_lazy(:note, &Fake.summary/0)
    |> Map.put_new_lazy(:image, &Fake.icon/0)
    # |> Map.put_new_lazy(:has_beginning, &Fake.past_datetime/0)
    |> Map.put_new_lazy(:action, &action/0)
    |> Map.put_new_lazy(:provider, &agent/0)
    |> Map.put_new_lazy(:receiver, &agent/0)
  end

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

  def fake_intent!(user, unit \\ nil, overrides \\ %{})

  def fake_intent!(user, unit, overrides) when is_nil(unit) do
    {:ok, intent} = Intents.create(user, action(), intent(overrides))
    intent
  end

  def fake_intent!(user, unit, overrides) do
    measure_attrs = %{unit_id: unit.id}
    measures = %{
      resource_quantity: measure(measure_attrs),
      effort_quantity: measure(measure_attrs),
      available_quantity: measure(measure_attrs)
    }
    overrides = Map.merge(overrides, measures)
    {:ok, intent} = Intents.create(user, action(), intent(overrides))
    intent
  end

  def fake_proposal!(user, overrides \\ %{}) do
    {:ok, proposal} = Proposals.create(user, proposal(overrides))
    proposal
  end

  def fake_proposed_intent!(proposal, intent, overrides \\ %{}) do
    {:ok, proposed_intent} = Proposals.propose_intent(proposal, intent, proposed_intent(overrides))
    proposed_intent
  end
end
