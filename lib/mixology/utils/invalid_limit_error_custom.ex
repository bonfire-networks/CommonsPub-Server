defmodule CommonsPub.Common.InvalidLimitErrorCustom do
   require ExtendModule
   ExtendModule.extends CommonsPub.Common.InvalidLimitError

   def new() do
    %__MODULE__{
      message:
        "The provided limit was invalid. It must be a positive integer no greater than 500",
      code: "invalid_limit",
      status: 400
    }
  end
end
