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


  describe "EconomicResources.track" do
    test "Returns a list of EconomicEvents that are inputs to Processes " do
      user = fake_user!()
      resource = fake_economic_resource!(user)
      process = fake_process!(user)
      input_events = some(3, fn -> fake_economic_event!(user, %{
        input_of: process.id,
        resource_inventoried_as: resource.id,
        action: "use"
      }) end)
      output_events = some(5, fn -> fake_economic_event!(user, %{
        output_of: process.id,
        resource_inventoried_as: resource.id,
        action: "produce"
      }) end)
      q = economic_resource_query(fields: [track: [:id]])
      conn = user_conn(user)

      assert resource = grumble_post_key(q, conn, :economic_resource, %{id: resource.id})
      assert Enum.count(resource["track"]) == 3
    end

    test "Returns a list of transfer/move EconomicEvents with the resource defined as the resourceInventoriedAs" do
      user = fake_user!()
      resource = fake_economic_resource!(user)
      input_events = some(3, fn -> fake_economic_event!(user, %{
        resource_inventoried_as: resource.id,
        action: "transfer"
      }) end)
      _other_events = some(5, fn -> fake_economic_event!(user, %{
        resource_inventoried_as: resource.id,
        action: "use"
      }) end)
      q = economic_resource_query(fields: [track: [:id]])
      conn = user_conn(user)

      assert resource = grumble_post_key(q, conn, :economic_resource, %{id: resource.id})
      assert Enum.count(resource["track"]) == 3
    end
  end

  describe "EconomicResources.trace" do
    test "Returns a list of EconomicEvents affecting it that are outputs to Processes " do
      user = fake_user!()
      resource = fake_economic_resource!(user)
      process = fake_process!(user)
      input_events = some(3, fn -> fake_economic_event!(user, %{
        input_of: process.id,
        resource_inventoried_as: resource.id,
        action: "use"
      }) end)
      output_events = some(5, fn -> fake_economic_event!(user, %{
        output_of: process.id,
        resource_inventoried_as: resource.id,
        action: "produce"
      }) end)
      q = economic_resource_query(fields: [trace: [:id]])
      conn = user_conn(user)

      assert resource = grumble_post_key(q, conn, :economic_resource, %{id: resource.id})
      assert Enum.count(resource["trace"]) == 5
    end

    test "Returns a list of transfer/move EconomicEvents with the resource defined as the toResourceInventoriedAs" do
      user = fake_user!()
      alice = fake_user!()
      resource = fake_economic_resource!(user)
      input_events = some(3, fn -> fake_economic_event!(user, %{
        provider: user.id,
        receiver: alice.id,
        to_resource_inventoried_as: resource.id,
        action: "transfer"
      }) end)
      _other_events = some(5, fn -> fake_economic_event!(user, %{
        provider: user.id,
        receiver: alice.id,
        to_resource_inventoried_as: resource.id,
        action: "use"
      }) end)
      q = economic_resource_query(fields: [trace: [:id]])
      conn = user_conn(user)

      assert resource = grumble_post_key(q, conn, :economic_resource, %{id: resource.id})
      assert Enum.count(resource["trace"]) == 3
    end
   end


end
