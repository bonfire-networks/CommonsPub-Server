# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Test.Faking do
  # import ExUnit.Assertions

  import CommonsPub.Web.Test.GraphQLAssertions
  import CommonsPub.Web.Test.GraphQLFields

  # import CommonsPub.Utils.Trendy

  # import ValueFlows.Simulate
  # import Measurement.Test.Faking
  import Grumble

  # alias CommonsPub.Utils.Simulation
  alias ValueFlows.Planning.Intent
  # alias ValueFlows.Planning.Intent.Intents
  alias ValueFlows.Knowledge.Action
  alias ValueFlows.Knowledge.ProcessSpecification

  alias ValueFlows.{
    Proposal
    # Proposals
  }

  alias ValueFlows.Proposal.{ProposedTo, ProposedIntent}

  def assert_action(%Action{} = action) do
    assert_action(Map.from_struct(action))
  end

  def assert_action(action) do
    assert_object(action, :assert_action,
      label: &assert_binary/1,
      input_output: assert_optional(&assert_binary/1),
      pairs_with: assert_optional(&assert_binary/1),
      resource_effect: &assert_binary/1,
      onhand_effect: assert_optional(&assert_binary/1),
      note: assert_optional(&assert_binary/1)
    )
  end

  def assert_proposal(%Proposal{} = proposal) do
    assert_proposal(Map.from_struct(proposal))
  end

  def assert_proposal(proposal) do
    assert_object(proposal, :assert_proposal,
      id: &assert_ulid/1,
      name: &assert_binary/1,
      note: &assert_binary/1,
      unit_based: &assert_boolean/1,
      has_beginning: assert_optional(&assert_datetime/1),
      has_end: assert_optional(&assert_datetime/1),
      created: assert_optional(&assert_datetime/1)
    )
  end

  def assert_proposal(%Proposal{} = proposal, %{} = proposal2) do
    assert_proposals_eq(proposal, assert_proposal(proposal2))
  end

  def assert_proposal_full(%Proposal{} = proposal) do
    assert_proposal_full(Map.from_struct(proposal))
  end

  def assert_proposal_full(proposal) do
    assert_object(proposal, :assert_proposal,
      id: &assert_ulid/1,
      name: &assert_binary/1,
      note: &assert_binary/1,
      unit_based: &assert_boolean/1,
      has_beginning: &assert_datetime/1,
      has_end: &assert_datetime/1,
      created: &assert_datetime/1
    )
  end

  def assert_proposal_full(%Proposal{} = proposal, %{} = proposal2) do
    assert_proposals_eq(proposal, assert_proposal_full(proposal2))
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

  def assert_proposed_intent(%ProposedIntent{} = pi) do
    assert_proposed_intent(Map.from_struct(pi))
  end

  def assert_proposed_intent(pi) do
    assert_object(pi, :assert_proposed_intent,
      id: &assert_ulid/1,
      reciprocal: assert_optional(&assert_boolean/1)
    )
  end

  def assert_proposed_to(%ProposedTo{} = pt) do
    assert_proposed_to(Map.from_struct(pt))
  end

  def assert_proposed_to(pt) do
    assert_object(pt, :assert_proposed_to, id: &assert_ulid/1)
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

  def assert_process_specification(%ProcessSpecification{} = spec) do
    assert_process_specification(Map.from_struct(spec))
  end

  def assert_process_specification(spec) do
    assert_object(spec, :assert_process_specification,
      name: &assert_binary/1,
      note: assert_optional(&assert_binary/1),
      # classified_as: assert_optional(assert_list(&assert_url/1))
    )
  end

  ## Graphql

  def action_fields(extra \\ []) do
    extra ++
      ~w(label input_output pairs_with resource_effect onhand_effect note)a
  end

  def action_subquery(options \\ []) do
    gen_subquery(:id, :action, &action_fields/1, options)
  end

  def actions_subquery(options \\ []) do
    fields = Keyword.get(options, :fields, [])
    fields = fields ++ action_fields(fields)
    field(:actions, [{:fields, fields} | options])
  end

  def action_query(options \\ []) do
    options = Keyword.put_new(options, :id_type, :id)
    gen_query(:id, &action_subquery/1, options)
  end

  def actions_query(options \\ []) do
    gen_query(&actions_subquery/1, options)
  end

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

  def intents_subquery(options \\ []) do
    fields = Keyword.get(options, :fields, [])
    fields = fields ++ intent_fields(fields)
    field(:intents, [{:fields, fields} | options])
  end

  def intents_query(options \\ []) do
    gen_query(&intents_subquery/1, options)
  end

  def intents_pages_subquery(options \\ []) do
    args = [
      after: var(:intents_after),
      before: var(:intents_before),
      limit: var(:intents_limit),
    ]

    page_subquery(
      :intents_pages,
      &intent_fields/1,
      [{:args, args} | options]
    )
  end

  def intents_pages_query(options \\ []) do
    params = [
      intents_after: list_type(:cursor),
      intents_before: list_type(:cursor),
      intents_limit: :int,
    ] ++ Keyword.get(options, :params, [])

    gen_query(&intents_pages_subquery/1, [{:params, params} | options])
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

  def proposal_fields(extra \\ []) do
    extra ++ ~w(id name note created has_beginning has_end unit_based)a
  end

  def proposal_response_fields(extra \\ []) do
    [proposal: proposal_fields(extra)]
  end

  def proposal_query(options \\ []) do
    options = Keyword.put_new(options, :id_type, :id)
    gen_query(:id, &proposal_subquery/1, options)
  end

  def proposal_subquery(options \\ []) do
    gen_subquery(:id, :proposal, &proposal_fields/1, options)
  end

  def create_proposal_mutation(options \\ []) do
    [proposal: type!(:proposal_create_params)]
    |> gen_mutation(&create_proposal_submutation/1, options)
  end

  def create_proposal_submutation(options \\ []) do
    [proposal: var(:proposal)]
    |> gen_submutation(:create_proposal, &proposal_response_fields/1, options)
  end

  def update_proposal_mutation(options \\ []) do
    [proposal: type!(:proposal_update_params)]
    |> gen_mutation(&update_proposal_submutation/1, options)
  end

  def update_proposal_submutation(options \\ []) do
    [proposal: var(:proposal)]
    |> gen_submutation(:update_proposal, &proposal_response_fields/1, options)
  end

  def delete_proposal_mutation(options \\ []) do
    [id: type!(:id)]
    |> gen_mutation(&delete_proposal_submutation/1, options)
  end

  def delete_proposal_submutation(_options \\ []) do
    field(:delete_proposal, args: [id: var(:id)])
  end

  def proposed_intent_fields(extra \\ []) do
    extra ++ ~w(id reciprocal)a
  end

  def proposed_intent_response_fields(extra \\ []) do
    [proposed_intent: proposed_intent_fields(extra)]
  end

  def propose_intent_mutation(options \\ []) do
    [
      published_in: type!(:id),
      publishes: type!(:id),
      reciprocal: type(:boolean)
    ]
    |> gen_mutation(&propose_intent_submutation/1, options)
  end

  def propose_intent_submutation(options \\ []) do
    [
      published_in: var(:published_in),
      publishes: var(:publishes),
      reciprocal: var(:reciprocal)
    ]
    |> gen_submutation(:propose_intent, &proposed_intent_response_fields/1, options)
  end

  def delete_proposed_intent_mutation(options \\ []) do
    [id: type!(:id)]
    |> gen_mutation(&delete_proposed_intent_submutation/1, options)
  end

  def delete_proposed_intent_submutation(_options \\ []) do
    field(:delete_proposed_intent, args: [id: var(:id)])
  end

  def proposed_to_fields(extra \\ []) do
    extra ++ ~w(id)a
  end

  def proposed_to_response_fields(extra \\ []) do
    [proposed_to: proposed_to_fields(extra)]
  end

  def propose_to_mutation(options \\ []) do
    [
      proposed: type!(:id),
      proposed_to: type!(:id)
    ]
    |> gen_mutation(&propose_to_submutation/1, options)
  end

  def propose_to_submutation(options \\ []) do
    [
      proposed: var(:proposed),
      proposed_to: var(:proposed_to)
    ]
    |> gen_submutation(:propose_to, &proposed_to_response_fields/1, options)
  end

  def delete_proposed_to_mutation(options \\ []) do
    [id: type!(:id)]
    |> gen_mutation(&delete_proposed_to_submutation/1, options)
  end

  def delete_proposed_to_submutation(_options \\ []) do
    field(:delete_proposed_to, args: [id: var(:id)])
  end

  def process_specification_fields(extra \\ []) do
    extra ++ ~w(id name note)a
  end

  def process_specification_response_fields(extra \\ []) do
    [process_specification: process_specification_fields(extra)]
  end

  def process_specification_query(options \\ []) do
    options = Keyword.put_new(options, :id_type, :id)
    gen_query(:id, &process_specification_subquery/1, options)
  end

  def process_specification_subquery(options \\ []) do
    gen_subquery(:id, :process_specification, &process_specification_fields/1, options)
  end

  def create_process_specification_mutation(options \\ []) do
    [process_specification: type!(:process_specification_create_params)]
    |> gen_mutation(&create_process_specification_submutation/1, options)
  end

  def create_process_specification_submutation(options \\ []) do
    [process_specification: var(:process_specification)]
    |> gen_submutation(:create_process_specification, &process_specification_response_fields/1, options)
  end

  def update_process_specification_mutation(options \\ []) do
    [process_specification: type!(:process_specification_update_params)]
    |> gen_mutation(&update_process_specification_submutation/1, options)
  end

  def update_process_specification_submutation(options \\ []) do
    [process_specification: var(:process_specification)]
    |> gen_submutation(:update_process_specification, &process_specification_response_fields/1, options)
  end

  def delete_process_specification_mutation(options \\ []) do
    [id: type!(:id)]
    |> gen_mutation(&delete_process_specification_submutation/1, options)
  end

  def delete_process_specification_submutation(_options \\ []) do
    field(:delete_process_specification, args: [id: var(:id)])
  end



end
