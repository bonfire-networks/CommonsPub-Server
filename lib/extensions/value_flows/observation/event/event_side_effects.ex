defmodule ValueFlows.Observation.EconomicEvent.EventSideEffects do
  import Logger

  alias CommonsPub.Repo

  alias ValueFlows.Observation.EconomicEvent
  alias ValueFlows.Observation.EconomicEvent.EconomicEvents
  alias ValueFlows.Observation.EconomicResource.EconomicResources
  alias ValueFlows.Observation.EconomicEvent.Queries

  def event_side_effects(
        %EconomicEvent{
          action: %{label: action, resource_effect: operation},
          resource_quantity: resource_quantity,
          resource_inventoried_as_id: resource_inventoried_as_id,
          to_resource_inventoried_as_id: to_resource_inventoried_as_id
        } = event
      )
      when not is_nil(resource_quantity) and not is_nil(resource_inventoried_as_id) and
             not is_nil(to_resource_inventoried_as_id) and operation == "decrementIncrement" do
    # we have two resources that can be affected, and an decrementIncrement action

    # preload quantities
    resource =
      Repo.preload(event.resource_inventoried_as, [:accounting_quantity, :onhand_quantity])

    to_resource =
      Repo.preload(event.to_resource_inventoried_as, [:accounting_quantity, :onhand_quantity])

    {:ok, resource, to_resource} =
      two_resources_update_quantities(resource, to_resource, resource_quantity, action)

    {:ok, %{event | resource_inventoried_as: resource, to_resource_inventoried_as: to_resource}}
  end

  def two_resources_update_quantities(resource, to_resource, by_quantity, action) do
    {:ok, resource, to_resource} =
      two_resources_update_onhand_quantity(resource, to_resource, by_quantity, action)

    {:ok, resource, to_resource} =
      two_resources_update_accounting_quantity(resource, to_resource, by_quantity, action)
  end

  def two_resources_update_onhand_quantity(resource, to_resource, by_quantity, action)
      when action == "transfer-custody" or action == "transfer-complete" or action == "move" do
    resource = resource_update_onhand_quantity(resource, by_quantity, "decrement")
    to_resource = resource_update_onhand_quantity(to_resource, by_quantity, "increment")

    {:ok, resource, to_resource}
  end

  def two_resources_update_onhand_quantity(resource, to_resource, _, _) do
    {:ok, resource, to_resource}
  end

  def two_resources_update_accounting_quantity(resource, to_resource, by_quantity, action)
      when action == "transfer-all-rights" or action == "transfer-complete" or action == "move" do
    resource = resource_update_accounting_quantity(resource, by_quantity, "decrement")
    to_resource = resource_update_accounting_quantity(to_resource, by_quantity, "increment")

    {:ok, resource, to_resource}
  end

  def two_resources_update_accounting_quantity(resource, to_resource, _, _) do
    {:ok, resource, to_resource}
  end

  def event_side_effects(
        %EconomicEvent{
          action: %{resource_effect: operation},
          resource_quantity: resource_quantity,
          resource_inventoried_as_id: resource_inventoried_as_id
        } = event
      )
      when not is_nil(resource_quantity) and not is_nil(resource_inventoried_as_id) do
    resource =
      Repo.preload(event.resource_inventoried_as, [:accounting_quantity, :onhand_quantity])

    resource = resource_update_quantities(resource, resource_quantity, operation)
    # IO.inspect(incremented: event)

    {:ok, %{event | resource_inventoried_as: resource}}
  end

  def event_side_effects(
        %EconomicEvent{
          action: %{resource_effect: "decrementIncrement"},
          resource_quantity: resource_quantity
        } = event
      )
      when not is_nil(resource_quantity) do
    Logger.warn("# TODO: https://lab.allmende.io/valueflows/vf-app-specs/vf-apps/-/issues/4")
    # IO.inspect(decrementIncrement: event)
    {:ok, event}
  end

  def event_side_effects(event) do
    # IO.inspect(event)
    {:ok, event}
  end

  def resource_update_quantities(
        resource,
        by_quantity,
        operation
      )
      when operation != "noEffect" do
    resource = resource_update_onhand_quantity(resource, by_quantity, operation)
    resource = resource_update_accounting_quantity(resource, by_quantity, operation)
  end

  def resource_update_quantities(_, _, _) do
    Logger.info("do not set quantities since action is noEffect?")
  end

  def resource_update_accounting_quantity({:error, error}, _, _) do
    {:error, error}
  end

  def resource_update_onhand_quantity(
        %{
          onhand_quantity: %{unit_id: onhand_unit} = onhand_quantity
        } = resource,
        %{unit_id: event_unit},
        _
      )
      when onhand_unit != event_unit do
    {:error,
     "The units used on the existing resource's onhand quantity do not match the event's unit"}
  end

  def resource_update_accounting_quantity(
        %{
          accounting_quantity: %{unit_id: accounting_unit} = accounting_quantity
        } = resource,
        %{unit_id: event_unit},
        _
      )
      when accounting_unit != event_unit do
    {:error,
     "The units used on the existing the resource's accounting quantity do not match the event's unit"}
  end

  def resource_update_onhand_quantity(
        %{
          onhand_quantity: %{unit_id: onhand_unit} = onhand_quantity
        } = resource,
        %{unit_id: event_unit} = by_quantity,
        operation
      )
      when onhand_unit == event_unit do
    Logger.warn("# TODO: Add/substract (#{operation}) by_quantity to onhandQuantity")
    resource
  end

  def resource_update_accounting_quantity(
        %{
          accounting_quantity: %{unit_id: accounting_unit} = accounting_quantity
        } = resource,
        %{unit_id: event_unit} = by_quantity,
        operation
      )
      when accounting_unit == event_unit do
    Logger.warn("# TODO: Add/substract event resourceQuantity to accountingQuantity ")
    resource
  end

  def resource_update_onhand_quantity(
        %{
          onhand_quantity_id: existing_quantity
        } = resource,
        by_quantity,
        _
      )
      when is_nil(existing_quantity) do
    Logger.warn("# TODO: Set onhandQuantity")
    resource
  end

  def resource_update_accounting_quantity(
        %{
          accounting_quantity_id: existing_quantity
        } = resource,
        by_quantity,
        _
      )
      when is_nil(existing_quantity) do
    Logger.warn("# TODO: Set accountingQuantity ")
    resource
  end
end
