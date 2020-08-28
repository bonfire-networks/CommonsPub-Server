# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Simulate do
  @moduledoc false

  import CommonsPub.Utils.Simulation
  import CommonsPub.Utils.Trendy

  import Measurement.Simulate

  alias ValueFlows.Planning.Intent.Intents
  alias ValueFlows.Proposals
  # alias ValueFlows.Proposal.ProposedIntent
  alias ValueFlows.Knowledge.Action.Actions

  ### Start fake data functions

  def agent_type(), do: Faker.Util.pick([:person, :organization])

  def agent(base \\ %{}) do
    base
    |> Map.put_new_lazy(:id, &uuid/0)
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:note, &summary/0)
    |> Map.put_new_lazy(:image, &image/0)
    |> Map.put_new_lazy(:agent_type, &agent_type/0)
  end

  def resource_specification(base \\ %{}) do
    base
    |> Map.put_new_lazy(:id, &uuid/0)
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:note, &summary/0)
    # |> Map.put_new_lazy(:image, &icon/0)
    # |> Map.put_new_lazy(:default_unit_of_effort, &unit/0)
    |> Map.put_new_lazy(:resource_classified_as, fn -> some(1..5, &url/0) end)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_disabled, &falsehood/0)
  end

  def inc_dec(), do: Faker.Util.pick(["increment", "decrement"])

  def action, do: Faker.Util.pick(Actions.actions_list())

  def action_id, do: action().id

  def economic_event(base \\ %{}) do
    base
    |> Map.put_new_lazy(:id, &uuid/0)
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:note, &summary/0)
    # |> Map.put_new_lazy(:image, &icon/0)
    |> Map.put_new_lazy(:action, &action/0)
    |> Map.put_new_lazy(:has_beginning, &past_datetime/0)
    |> Map.put_new_lazy(:has_end, &future_datetime/0)
    |> Map.put_new_lazy(:has_point_in_time, &future_datetime/0)
    |> Map.put_new_lazy(:input_of, &process/0)
    |> Map.put_new_lazy(:output_of, &process/0)
    |> Map.put_new_lazy(:resource_inventoried_as, &economic_resource/0)
    |> Map.put_new_lazy(:to_resource_inventoried_as, &economic_resource/0)
    |> Map.put_new_lazy(:resource_conforms_to, &resource_specification/0)
    |> Map.put_new_lazy(:resource_classified_as, fn -> some(1..5, &url/0) end)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_disabled, &falsehood/0)
  end

  def economic_resource(base \\ %{}) do
    base
    |> Map.put_new_lazy(:id, &uuid/0)
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:note, &summary/0)
    |> Map.put_new_lazy(:tracking_identifier, &uuid/0)
    |> Map.put_new_lazy(:conforms_to, &resource_specification/0)
    |> Map.put_new_lazy(:state, &action/0)
    # |> Map.put_new_lazy(:accounting_quantity, &measure/0)
    # |> Map.put_new_lazy(:onhand_quantity, &measure/0)
    # |> Map.put_new_lazy(:unit_of_effort, &unit/0)
    # |> Map.put_new_lazy(:image, &icon/0)
    |> Map.put_new_lazy(:classified_as, fn -> some(1..5, &url/0) end)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_disabled, &falsehood/0)
  end

  def process(base \\ %{}) do
    base
    |> Map.put_new_lazy(:id, &uuid/0)
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:note, &summary/0)
    # |> Map.put_new_lazy(:image, &icon/0)
    |> Map.put_new_lazy(:resource_classified_as, fn -> some(1..5, &url/0) end)
    |> Map.put_new_lazy(:finished, &bool/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_disabled, &falsehood/0)
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

  def proposal_input(base \\ %{}) do
    base
    |> Map.put_new_lazy("name", &name/0)
    |> Map.put_new_lazy("note", &summary/0)
    |> Map.put_new_lazy("hasBeginning", &past_datetime_iso/0)
    |> Map.put_new_lazy("hasEnd", &future_datetime_iso/0)
    |> Map.put_new_lazy("created", &future_datetime_iso/0)
    |> Map.put_new_lazy("unitBased", &bool/0)
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
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:note, &summary/0)
    # |> Map.put_new_lazy(:image, &icon/0)
    |> Map.put_new_lazy(:action, &action_id/0)
    |> Map.put_new_lazy(:has_beginning, &past_datetime/0)
    |> Map.put_new_lazy(:has_end, &future_datetime/0)
    |> Map.put_new_lazy(:has_point_in_time, &future_datetime/0)
    |> Map.put_new_lazy(:due, &future_datetime/0)
    # TODO: list of URIs
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
    |> Map.put_new_lazy("action", &action_id/0)
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
    {:ok, proposed_intent} =
      Proposals.propose_intent(proposal, intent, proposed_intent(overrides))

    proposed_intent
  end
end
