defmodule Valueflows.Agent.Person.GraphQLTest do
  use CommonsPub.Web.ConnCase, async: true

  import CommonsPub.Test.Faking
  import CommonsPub.Utils.Simulation
  import CommonsPub.Web.Test.GraphQLAssertions

  import Geolocation.Test.Faking

  import ValueFlows.Simulate
  import ValueFlows.Test.Faking

  @debug true
  @schema CommonsPub.Web.GraphQL.Schema

  describe "person" do
    test "fetches an existing person by id (via HTTP)" do
      user = fake_user!()

      q = person_query()
      conn = user_conn(user)
      assert_agent(grumble_post_key(q, conn, :person, %{id: user.id}, "test", @debug))
    end

    test "fetches an existing person by id (via Absinthe.run)" do
      user = fake_user!()
      user2 = fake_user!()

      # attach some data to the person...

      intent =
        fake_intent!(user, nil, nil, %{
          provider: user.id
        })


      resource =
        fake_economic_resource!(user, %{
          primary_accountable: user.id
        })
      IO.inspect(resource: resource)

      process = fake_process!(user)

      event =
        fake_economic_event!(user, %{
          provider: user.id,
          receiver: user2.id,
          action: action.id,
          input_of: fake_process!(user2).id,
          output_of: fake_process!(user).id,
          resource_conforms_to: fake_resource_specification!(user).id,
          to_resource_inventoried_as: fake_economic_resource!(user).id,
          resource_inventoried_as: fake_economic_resource!(user).id
        })

      assert queried =
               CommonsPub.Web.GraphQL.QueryHelper.run_query_id(
                 user.id,
                 @schema,
                 :person,
                 3,
                 nil,
                 @debug
               )

      assert_agent(queried)
      # assert_optional(assert_url(queried["image"]))
      assert_intent(List.first(queried["intents"]))
      assert_process(List.first(queried["processes"]))
      assert_economic_event(List.first(queried["economicEvents"]))
      assert_economic_resource(List.first(queried["inventoriedEconomicResources"]))
      assert_geolocation(queried["primaryLocation"])
    end
  end

  describe "persons" do
    test "fetches all" do
      user = fake_user!()
      people = ValueFlows.Agent.People.people(user)
      num_people = Enum.count(people)

      q = people_query()
      conn = user_conn(user)

      assert fetched = grumble_post_key(q, conn, :people, %{})
      assert num_people == Enum.count(fetched)
    end
  end
end
