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
      assert {:ok, resource} = EconomicResources.create(user, economic_resource())
      assert_economic_resource(resource)
    end

    test "can create an economic resource with conforms_to" do
      user = fake_user!()
      assert {:ok, resource} = EconomicResources.create(user, economic_resource())
      assert_economic_resource(resource)
    end

    test "can create an economic resource with contained_in" do
      user = fake_user!()
      assert {:ok, resource} = EconomicResources.create(user, economic_resource())
      assert_economic_resource(resource)
    end

    test "can create an economic resource with primary_accountable" do
      user = fake_user!()
      assert {:ok, resource} = EconomicResources.create(user, economic_resource())
      assert_economic_resource(resource)
    end

    test "can create an economic resource with accounting_quantity and onhand_quantity" do
      user = fake_user!()
      assert {:ok, resource} = EconomicResources.create(user, economic_resource())
      assert_economic_resource(resource)
    end

    test "can create an economic resource with unit_of_effort" do
      user = fake_user!()
      assert {:ok, resource} = EconomicResources.create(user, economic_resource())
      assert_economic_resource(resource)
    end


  end

  describe "update" do

  end

  describe "soft_delete" do
  end

end
