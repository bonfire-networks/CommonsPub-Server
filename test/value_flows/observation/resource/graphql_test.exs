defmodule ValueFlows.Observation.EconomicResource.GraphQLTest do
  use CommonsPub.Web.ConnCase, async: true

  import CommonsPub.Utils.Trendy, only: [some: 2]
  import CommonsPub.Utils.Simulation
  import CommonsPub.Test.Faking

  import Measurement.Simulate
  import Measurement.Test.Faking

  import ValueFlows.Simulate
  import ValueFlows.Test.Faking
  alias Grumble.PP
  alias ValueFlows.Observation.EconomicResource.EconomicResources

  import Geolocation.Simulate
  import Geolocation.Test.Faking


  describe "EconomicResource" do
    test "fetches an economic resource by ID" do
      user = fake_user!()
      resource = fake_economic_resource!(user)

      q = economic_resource_query()
      conn = user_conn(user)
      assert fetched = grumble_post_key(q, conn, :economic_resource, %{id: resource.id})
      assert_economic_resource(fetched)
    end

    test "fail if has been deleted" do
      user = fake_user!()
      resource = fake_economic_resource!(user)

      q = economic_resource_query()
      conn = user_conn(user)

      assert {:ok, spec} = EconomicResources.soft_delete(resource)
      assert [%{"code" => "not_found", "path" => ["economicResource"], "status" => 404}] =
      grumble_post_errors(q, conn, %{id: resource.id})
    end
  end

  describe "EconomicResources" do
    test "return a list of economicResources" do
      user = fake_user!()
      resources = some(5, fn -> fake_economic_resource!(user) end)
      # deleted
      some(2, fn ->
        resource = fake_economic_resource!(user)
        {:ok, resource} = EconomicResources.soft_delete(resource)
        resource
      end)
      q = economic_resources_query()
      conn = user_conn(user)

      assert fetched_economic_resources = grumble_post_key(q, conn, :economic_resources, %{})
      assert Enum.count(resources) == Enum.count(fetched_economic_resources)

    end
  end

  describe "EconomicResourcesPages" do
    test "return a list of economicResources" do
      user = fake_user!()
      resources = some(5, fn -> fake_economic_resource!(user) end)
      # deleted
      some(2, fn ->
        resource = fake_economic_resource!(user)
        {:ok, resource} = EconomicResources.soft_delete(resource)
        resource
      end)
      q = economic_resources_pages_query()
      conn = user_conn(user)

      assert page = grumble_post_key(q, conn, :economic_resources_pages, %{})
      assert Enum.count(resources) == page["totalCount"]
    end
  end




end
