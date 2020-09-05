# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Users.Me do
  @enforce_keys [:user]
  defstruct @enforce_keys

  def new(user) do
    %__MODULE__{user: user}
  end
end
