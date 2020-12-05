defmodule Bonfire.Quantify.Simulate do
  import CommonsPub.Utils.Simulation
  # import CommonsPub.Utils.Trendy

  alias Bonfire.Quantify.Units
  alias Bonfire.Quantify.Measures

  @doc "A unit"
  def unit_name(), do: Faker.Util.pick(["kilo", "liter"])
  def unit_symbol(), do: Faker.Util.pick(["kg", "m"])

  ### Start fake data functions

  ## Unit

  def unit(base \\ %{}) do
    base
    |> Map.put_new_lazy(:label, &unit_name/0)
    |> Map.put_new_lazy(:symbol, &unit_symbol/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
    |> Map.put_new_lazy(:is_disabled, &falsehood/0)
    |> Map.put_new_lazy(:is_featured, &falsehood/0)
    |> Map.merge(character(base))
  end

  def unit_input(base \\ %{}) do
    base
    |> Map.put_new_lazy("label", &unit_name/0)
    |> Map.put_new_lazy("symbol", &unit_symbol/0)
  end

  def fake_unit!(user, context \\ nil, overrides \\ %{})

  def fake_unit!(user, context, overrides) when is_nil(context) do
    {:ok, unit} = Units.create(user, unit(overrides))
    unit
  end

  def fake_unit!(user, context, overrides) do
    {:ok, unit} = Units.create(user, context, unit(overrides))
    unit
  end

  ## Measures

  def measure(overrides \\ %{}) do
    overrides
    |> Map.put_new_lazy(:has_numerical_value, &float/0)
    |> Map.put_new_lazy(:is_public, &truth/0)
  end

  def measure_input(unit \\ nil, overrides \\ %{}) do
    overrides = Map.put_new_lazy(overrides, "hasNumericalValue", &:rand.uniform/0)

    if is_nil(unit) do
      overrides
    else
      Map.put_new(overrides, "hasUnit", unit.id)
    end
  end

  def fake_measure!(user, unit, overrides \\ %{}) do
    {:ok, measure} = Measures.create(user, unit, measure(overrides))
    measure
  end
end
