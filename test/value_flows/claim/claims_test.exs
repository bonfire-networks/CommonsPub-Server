defmodule ValueFlows.Claim.ClaimsTest do
  use CommonsPub.Web.ConnCase, async: true

  import CommonsPub.Test.Faking
  import Measurement.Simulate
  import ValueFlows.Simulate
  import ValueFlows.Test.Faking

  alias ValueFlows.Claim.Claims

  describe "create" do
    test "with only required parameters" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()

      assert {:ok, claim} = Claims.create(user, provider, receiver, claim())
      assert_claim(claim)
      assert claim.creator.id == user.id
      assert claim.provider.id == provider.id
      assert claim.receiver.id == receiver.id
    end

    test "with a context" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()

      attrs = %{
        in_scope_of: [fake_community!(user).id]
      }

      assert {:ok, claim} = Claims.create(user, provider, receiver, claim(attrs))
      assert_claim(claim)
      assert claim.context.id == hd(attrs.in_scope_of)
    end

    test "with measure quantities" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()

      unit = fake_unit!(user)
      attrs = %{
        resource_quantity: measure(%{unit_id: unit.id}),
        effort_quantity: measure(%{unit_id: unit.id}),
      }

      assert {:ok, claim} = Claims.create(user, provider, receiver, claim(attrs))
      assert_claim(claim)
      assert claim.resource_quantity.id
      assert claim.effort_quantity.id
    end

    test "with a resource specification" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()

      attrs = %{
        resource_conforms_to: fake_resource_specification!(user).id
      }

      assert {:ok, claim} = Claims.create(user, provider, receiver, claim(attrs))
      assert_claim(claim)
      assert claim.resource_conforms_to.id == attrs.resource_conforms_to
    end

    test "with a triggered by event" do
      user = fake_user!()
      provider = fake_user!()
      receiver = fake_user!()

      attrs = %{
        triggered_by: fake_economic_event!(user).id
      }

      assert {:ok, claim} = Claims.create(user, provider, receiver, claim(attrs))
      assert_claim(claim)
      assert claim.triggered_by.id == attrs.triggered_by
    end
  end
end
