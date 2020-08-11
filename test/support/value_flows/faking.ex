# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Test.Faking do
  import ExUnit.Assertions

  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields

  import CommonsPub.Utils.Trendy

  import ValueFlows.Simulate
  import Measurement.Test.Faking
  import Grumble

  alias CommonsPub.Utils.Simulation
  alias ValueFlows.Planning.Intent
  alias ValueFlows.Planning.Intent.Intents
  alias ValueFlows.Proposal
  alias ValueFlows.Proposals

  def assert_proposal(%Proposal{} = proposal) do
    assert_proposal(Map.from_struct(intent))
  end

  def assert_proposal(proposal) do
    assert_object(proposal, :assert_proposal,
      id: &assert_ulid/1,
      name: &assert_binary/1,
      note: &assert_binary/1,
      unit_based: &assert_boolean/1,
      # TODO
      # resource_quantity: assert_optional(&assert_measure/1),
      # effort_quantity: assert_optional(&assert_measure/1),
      # available_quantity: assert_optional(&assert_measure/1),
      has_beginning: assert_optional(&assert_datetime/1),
      has_end: assert_optional(&assert_datetime/1),
      created: assert_optional(&assert_datetime/1)
    )
  end

  def assert_proposal(%Proposal{} = proposal, %{} = proposal2) do
    assert_proposals_eq(proposal, assert_proposal(proposal2))
  end

  def assert_proposals_eq(%Proposal{} = proposal, %{} = proposal2) do
    assert_maps_eq(proposal, proposal2, :assert_proposal, [
      :name,
      :note,
      :unit_based,
      :has_beginning,
      :has_end,
      :created
    ])
  end

  def assert_intent(%Intent{} = intent) do
    assert_intent(Map.from_struct(intent))
  end

  def assert_intent(intent) do
    assert_object(intent, :assert_intent,
      id: &assert_ulid/1,
      name: &assert_binary/1,
      note: &assert_binary/1,
      finished: &assert_boolean/1,
      # TODO
      # resource_quantity: assert_optional(&assert_measure/1),
      # effort_quantity: assert_optional(&assert_measure/1),
      # available_quantity: assert_optional(&assert_measure/1),
      has_beginning: assert_optional(&assert_datetime/1),
      has_end: assert_optional(&assert_datetime/1),
      has_point_in_time: assert_optional(&assert_datetime/1),
      due: assert_optional(&assert_datetime/1),
      resource_classified_as: assert_optional(assert_list(&assert_url/1))
    )
  end

  def assert_intent(%Intent{} = intent, %{} = intent2) do
    assert_intents_eq(intent, assert_intent(intent2))
  end

  def assert_intents_eq(%Intent{} = intent, %{} = intent2) do
    assert_maps_eq(intent, intent2, :assert_intent, [
      :name,
      :note,
      :finished,
      :has_beginning,
      :has_end,
      :has_point_in_time,
      :due
    ])
  end

  ## Graphql

  def intent_fields(extra \\ []) do
    extra ++
      ~w(id name note has_beginning has_end has_point_in_time due finished)a ++
      ~w(resource_classified_as)a
  end

  def intent_response_fields(extra \\ []) do
    [intent: intent_fields(extra)]
  end

  def intent_subquery(options \\ []) do
    gen_subquery(:id, :intent, &intent_fields/1, options)
  end

  def intent_query(options \\ []) do
    options = Keyword.put_new(options, :id_type, :id)
    gen_query(:id, &intent_subquery/1, options)
  end

  def create_offer_mutation(options \\ []) do
    [intent: type!(:intent_create_params)]
    |> gen_mutation(&create_offer_submutation/1, options)
  end

  def create_offer_submutation(options \\ []) do
    [intent: var(:intent)]
    |> gen_submutation(:create_offer, &intent_response_fields/1, options)
  end

  def create_need_mutation(options \\ []) do
    [intent: type!(:intent_create_params)]
    |> gen_mutation(&create_need_submutation/1, options)
  end

  def create_need_submutation(options \\ []) do
    [intent: var(:intent)]
    |> gen_submutation(:create_need, &intent_response_fields/1, options)
  end

  def create_intent_mutation(options \\ []) do
    [intent: type!(:intent_create_params)]
    |> gen_mutation(&create_intent_submutation/1, options)
  end

  def create_intent_submutation(options \\ []) do
    [intent: var(:intent)]
    |> gen_submutation(:create_intent, &intent_response_fields/1, options)
  end

  def update_intent_mutation(options \\ []) do
    [intent: type!(:intent_update_params)]
    |> gen_mutation(&update_intent_submutation/1, options)
  end

  def update_intent_submutation(options \\ []) do
    [intent: var(:intent)]
    |> gen_submutation(:update_intent, &intent_response_fields/1, options)
  end

  def delete_intent_mutation(options \\ []) do
    [id: type!(:id)]
    |> gen_mutation(&delete_intent_submutation/1, options)
  end

  def delete_intent_submutation(_options \\ []) do
    field(:delete_intent, args: [id: var(:id)])
  end
end
