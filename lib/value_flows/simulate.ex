# Based on code from MoodleNet
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Simulate do
  @moduledoc false

  import CommonsPub.Utils.Simulation
  import CommonsPub.Utils.Trendy

  import Measurement.Simulate

  alias ValueFlows.Planning.Intent.Intents
  alias ValueFlows.Proposal.Proposals

  alias ValueFlows.Knowledge.Action.Actions

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

  def action, do: Faker.Util.pick(Actions.actions_list())

  def action_id, do: action().id

  def proposal(base \\ %{}) do
    base
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:note, &summary/0)
    # |> Map.put_new_lazy(:image, &icon/0)
    |> Map.put_new_lazy(:has_beginning, &past_datetime/0)
    |> Map.put_new_lazy(:has_end, &future_datetime/0)
    |> Map.put_new_lazy(:created, &future_datetime/0)
    # TODO: list of URI's
    |> Map.put_new_lazy(:unit_based, &bool/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_disabled, &falsehood/0)
  end

  def intent(base \\ %{}) do
    base
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:note, &summary/0)
    # |> Map.put_new_lazy(:image, &icon/0)
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
    |> Map.put_new_lazy("action", &action_id/0)
    # |> Map.put_new_lazy("image", &icon/0)
    |> Map.put_new_lazy("resource_classified_as", fn -> some(1..5, &url/0) end)
    |> Map.put_new_lazy("has_beginning", &past_datetime_iso/0)
    |> Map.put_new_lazy("has_end", &future_datetime_iso/0)
    |> Map.put_new_lazy("has_point_in_time", &future_datetime_iso/0)
    |> Map.put_new_lazy("due", &future_datetime_iso/0)
    |> Map.put_new_lazy("finished", &bool/0)
    |> Map.put_new_lazy("available_quantity", fn -> measure_input(unit) end)
    |> Map.put_new_lazy("resource_quantity", fn -> measure_input(unit) end)
    |> Map.put_new_lazy("effort_quantity", fn -> measure_input(unit) end)
  end

  def fake_intent!(user, unit, overrides \\ %{}) do
    measure_attrs = %{unit_id: unit.id}
    measures = %{
      resource_quantity: measure(measure_attrs),
      effort_quantity: measure(measure_attrs),
      available_quantity: measure(measure_attrs)
    }
    {:ok, intent} = Intents.create(user, action(), intent(measures))
    intent
  end

  def fake_proposal!(user, overrides \\ %{}) do
    {:ok, proposal} = Proposals.create(user, proposal())
    proposal
  end


end
