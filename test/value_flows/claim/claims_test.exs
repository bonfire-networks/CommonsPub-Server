defmodule ValueFlows.Claim.ClaimsTest do
  use CommonsPub.Web.ConnCase, async: true

  import CommonsPub.Test.Faking
  import ValueFlows.Simulate
  import ValueFlows.Test.Faking

  alias ValueFlows.Claim
  alias ValueFlows.Claim.Claims

  describe "create" do
    test "creates a new claim with a creator" do
      user = fake_user!()

      assert {:ok, %Claim{} = claim} = Claims.create(user, claim())
    end
  end
end
