defmodule ValueFlows.Observation.EconomicResource.EconomicResourcesTest do
  use CommonsPub.Web.ConnCase, async: true

  import CommonsPub.Test.Faking
  import CommonsPub.Utils.{Trendy, Simulation}
  import ValueFlows.Simulate
  import Measurement.Simulate
  import Geolocation.Simulate

  import ValueFlows.Test.Faking

  alias ValueFlows.Observation.EconomicResource.EconomicResources

  describe "one" do
    test "fetches an existing economic resource by ID" do
     user = fake_user!()
     resource = fake_economic_resource!(user)
     assert {:ok, fetched} = EconomicResources.one(id: resource.id)
     assert_economic_resource(fetched)
     assert {:ok, fetched} = EconomicResources.one(user: user)
     assert_economic_resource(fetched)
    end

  end

  describe "create" do
    test "can create an economic resource" do
      user = fake_user!()
      assert {:ok, resource} = EconomicResources.create(user, economic_resource())
      assert_economic_resource(resource)
    end

    test "can create an economic resource with current_location" do
      user = fake_user!()
      location = fake_geolocation!(user)
      attrs = %{
        current_location: location.id
      }
      assert {:ok, resource} = EconomicResources.create(user, economic_resource(attrs))
      assert_economic_resource(resource)
      assert resource.current_location.id == attrs.current_location
    end

    test "can create an economic resource with conforms_to" do
      user = fake_user!()
      attrs = %{
        conforms_to: fake_resource_specification!(user).id,
      }
      assert {:ok, resource} = EconomicResources.create(user, economic_resource(attrs))
      assert_economic_resource(resource)
      assert resource.conforms_to.id == attrs.conforms_to
    end

    test "can create an economic resource with contained_in" do
      user = fake_user!()
      attrs = %{
        contained_in: fake_economic_resource!(user).id,
      }
      assert {:ok, resource} = EconomicResources.create(user, economic_resource(attrs))
      assert_economic_resource(resource)
      assert resource.contained_in.id == attrs.contained_in
    end

    test "can create an economic resource with primary_accountable" do
      user = fake_user!()
      owner = fake_user!()
      attrs = %{
        primary_accountable: owner.id
      }
      assert {:ok, resource} = EconomicResources.create(user, economic_resource(attrs))
      assert_economic_resource(resource)
      assert resource.primary_accountable.id == attrs.primary_accountable
    end

    test "can create an economic resource with accounting_quantity and onhand_quantity" do
      user = fake_user!()
      unit = fake_unit!(user)
      attrs = %{
        accounting_quantity: measure(%{unit_id: unit.id}),
        onhand_quantity: measure(%{unit_id: unit.id}),
      }

      assert {:ok, resource} = EconomicResources.create(user, economic_resource(attrs))
      assert_economic_resource(resource)
      assert resource.onhand_quantity.id
      assert resource.accounting_quantity.id
    end

    test "can create an economic resource with unit_of_effort" do
      user = fake_user!()
      attrs = %{
        unit_of_effort: fake_unit!(user).id,
      }
      assert {:ok, resource} = EconomicResources.create(user, economic_resource(attrs))
      assert_economic_resource(resource)
      assert resource.unit_of_effort.id === attrs.unit_of_effort
    end

  end


  describe "update" do
    test "update an existing resource" do
      user = fake_user!()
      unit = fake_unit!(user)
      resource = fake_economic_resource!(user)
      attrs = %{
        accounting_quantity: measure(%{unit_id: unit.id}),
        onhand_quantity: measure(%{unit_id: unit.id}),
      }
      assert {:ok, updated} = EconomicResources.update(resource, economic_resource(attrs))
      assert_economic_resource(updated)
      assert resource != updated
      assert resource.accounting_quantity_id != updated.accounting_quantity_id
      assert resource.onhand_quantity_id != updated.onhand_quantity_id
    end
  end
end
