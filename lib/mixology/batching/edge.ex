# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Batching.Edge do
  @enforce_keys [:cursor, :node]
  defstruct @enforce_keys

  alias CommonsPub.Batching.Edge

  @type t :: %Edge{
          node: term,
          cursor: binary
        }

  def new(node, cursor) when is_binary(cursor) do
    %Edge{cursor: cursor, node: node}
  end

  def new(node, cursor_fn) when is_function(cursor_fn, 1) do
    %Edge{cursor: cursor_fn.(node), node: node}
  end
end
