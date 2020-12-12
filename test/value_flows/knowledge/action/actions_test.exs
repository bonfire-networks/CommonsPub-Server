defmodule ValueFlows.Knowledge.Action.ActionsTest do
  use CommonsPub.Web.ConnCase, async: true

  import Bonfire.Common.Simulation
  import CommonsPub.Utils.Simulate

  import ValueFlows.Simulate
  import ValueFlows.Test.Faking

  alias ValueFlows.Knowledge.Action.Actions


  describe "action" do
    test "fetches an action" do
      assert {:ok, fetched} = Actions.action(:move)
      assert_action(fetched)
      assert {:ok, fetched} = Actions.action("move")
      assert_action(fetched)
    end
  end

end
