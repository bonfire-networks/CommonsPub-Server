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

  end

  describe "update" do

  end

  describe "soft_delete" do
  end

end
