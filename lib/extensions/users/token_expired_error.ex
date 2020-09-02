# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Users.TokenExpiredError do
  @enforce_keys [:message, :code, :status]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
          message: binary,
          code: binary,
          status: integer
        }

  @doc "Create a new TokenExpiredError"
  @spec new() :: t
  def new() do
    %__MODULE__{
      message: "The token has expired.",
      code: "token_expired",
      status: 403
    }
  end
end
