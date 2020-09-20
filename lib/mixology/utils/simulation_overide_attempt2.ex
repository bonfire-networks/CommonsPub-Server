alias CommonsPub.Utils.Simulation, as: ReplaceModule

ModuleOverride.archive_module(ReplaceModule, Path.dirname(__ENV__.file) <> "/simulation.ex")

defmodule ReplaceModule do
  require ModuleExtend
  ModuleExtend.extends(ModuleOverride.CommonsPub.Utils.Simulation)

  @moduledoc """
  (Re)define new or existing functions
  """

  def location(), do: Faker.Address.country()
end
