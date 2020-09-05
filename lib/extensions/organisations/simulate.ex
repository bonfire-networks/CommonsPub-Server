defmodule Organisation.Simulate do
  import CommonsPub.Utils.Simulation
  # import CommonsPub.Utils.Trendy

  alias Organisation.Organisations

  def organisation(base \\ %{}) do
    base
    |> Map.put_new_lazy(:name, &name/0)
    |> Map.put_new_lazy(:summary, &summary/0)
    |> Map.put_new_lazy(:preferred_username, &preferred_username/0)
  end

  def fake_organisation!(user, overrides \\ %{}) do
    {:ok, org} = Organisations.create(user, organisation(overrides))
    org
  end
end
