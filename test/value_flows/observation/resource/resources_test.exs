defmodule ValueFlows.Observation.EconomicResource.EconomicResourcesTest do
  use CommonsPub.Web.ConnCase, async: true

  import CommonsPub.Test.Faking
  import CommonsPub.Tag.Simulate

  import CommonsPub.Utils.{Trendy, Simulation}

  import ValueFlows.Simulate
  import Measurement.Simulate
  import Geolocation.Simulate

  import ValueFlows.Test.Faking

  alias ValueFlows.Observation.EconomicResource.EconomicResources

  describe "one" do
    test "fetches an existing economic resource by ID" do
      user = fake_user!()

      assert {:ok, resource} = EconomicResources.create(user, economic_resource())

      assert {:ok, fetched} = EconomicResources.one(id: resource.id)
      assert_economic_resource(fetched)
    end
  end

  describe "create" do
    test "can create an economic resource (usually should be done via EconomicEvent)" do
      user = fake_user!()
      assert {:ok, resource} = EconomicResources.create(user, economic_resource())
      assert_economic_resource(resource)
    end

    test "can create an economic resource with primary_accountable" do
      user = fake_user!()

      attrs = %{
        primary_accountable: user.id
      }

      assert {:ok, resource} = EconomicResources.create(user, economic_resource(attrs))
      assert_economic_resource(resource)
      assert resource.primary_accountable.id == attrs.primary_accountable
    end

    test "can create an economic resource with tags" do
      user = fake_user!()

      tags = some(5, fn -> fake_category!(user).id end)
      attrs = %{tags: tags}

      assert {:ok, resource} = EconomicResources.create(user, economic_resource(attrs))
      assert_economic_resource(resource)

      resource = CommonsPub.Repo.preload(resource, :tags)
      assert Enum.count(resource.tags) == Enum.count(tags)
    end

    test "can create an economic resource with conforms_to" do
      user = fake_user!()

      attrs = %{
        conforms_to: fake_resource_specification!(user).id
      }

      assert {:ok, resource} = EconomicResources.create(user, economic_resource(attrs))
      assert_economic_resource(resource)
      assert resource.conforms_to.id == attrs.conforms_to
    end

    test "can create an economic resource with contained_in" do
      user = fake_user!()

      attrs = %{
        contained_in: fake_economic_resource!(user).id
      }

      assert {:ok, resource} = EconomicResources.create(user, economic_resource(attrs))
      assert_economic_resource(resource)
      assert resource.contained_in.id == attrs.contained_in
    end

    test "can create an economic resource with unit_of_effort, resource_quantity, and effort_quantity" do
      user = fake_user!()
      unit = fake_unit!(user)

      measures = %{
        unit_of_effort: unit.id,
        accounting_quantity: measure(%{unit_id: unit.id}),
        onhand_quantity: measure(%{unit_id: unit.id})
      }

      assert {:ok, resource} =
               EconomicResources.create(
                 user,
                 economic_resource(measures)
               )

      assert_economic_resource(resource)
      assert resource.unit_of_effort.id == unit.id
      assert resource.accounting_quantity.id
      assert resource.onhand_quantity.id
    end

    test "can create an economic resource with state" do
      user = fake_user!()
      state = action()

      attrs = %{
        state: state.id
      }

      assert {:ok, resource} = EconomicResources.create(user, economic_resource(attrs))
      assert_economic_resource(resource)
      assert resource.state_id == attrs.state
    end

    test "can create an economic resource with location" do
      user = fake_user!()
      location = fake_geolocation!(user)

      attrs = %{
        current_location: location.id
      }

      assert {:ok, resource} = EconomicResources.create(user, economic_resource(attrs))
      assert_economic_resource(resource)
      assert resource.current_location.id == attrs.current_location
    end
  end

  describe "update" do
  end

  describe "soft_delete" do
  end
end
