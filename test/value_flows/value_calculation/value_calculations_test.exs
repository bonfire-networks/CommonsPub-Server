defmodule ValueFlows.ValueCalculation.ValueCalculationsTest do
  use CommonsPub.Web.ConnCase, async: true

  import CommonsPub.Test.Faking
  import Measurement.Simulate
  import ValueFlows.Simulate
  import ValueFlows.Test.Faking

  alias ValueFlows.ValueCalculation.ValueCalculations

  describe "create" do
    test "with only required parameters" do
      user = fake_user!()

      assert {:ok, calc} = ValueCalculations.create(user, value_calculation())
      assert_value_calculation(calc)
      assert calc.creator.id == user.id
    end

    test "with a complex formula" do

    end

    test "with an invalid formula" do

    end

    test "with a context" do
      user = fake_user!()
      context = fake_community!(user)

      attrs = %{in_scope_of: [context.id]}
      assert {:ok, calc} = ValueCalculations.create(user, value_calculation(attrs))
      assert_value_calculation(calc)
      assert calc.context.id == context.id
    end

    test "with a value unit" do
      user = fake_user!()
      unit = fake_unit!(user)

      attrs = %{value_unit: unit.id}
      assert {:ok, calc} = ValueCalculations.create(user, value_calculation(attrs))
      assert_value_calculation(calc)
      assert calc.value_unit.id == unit.id
    end
  end
end
