# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Users.AuthPayload do
  @enforce_keys [:token, :me]
  defstruct @enforce_keys

  def new(token, me), do: %__MODULE__{token: token, me: me}
end
