# module that we will override
alias CommonsPub.Utils.Simulation, as: NewModule
# new name for the old module
alias Original.CommonsPub.Utils.Simulation, as: ArchiveModule

# archive the old module
Modularity.Module.Override.clone(NewModule, ArchiveModule)

defmodule NewModule do
  require Modularity.Module.Extend

  # extend the archived module
  Modularity.Module.Extend.extends ArchiveModule

  ####
  # (Re)define new or existing functions
  ####

  # example of straight up replacing a function
  def name(), do: Faker.Person.last_name()

  # example of modifying the input of a function
  # def maybe_one_of(list), do: list ++ [""] |> ArchiveModule.maybe_one_of()

  # example of modifying the output of a function
  def location(), do: ArchiveModule.location() |> String.replace(",", " -")

end
