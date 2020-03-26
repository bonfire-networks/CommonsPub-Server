# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.Cursor do
  defstruct [data: nil, normalized: nil, raw: nil, errors: [], flags: %{}]

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.Cursor
  alias Absinthe.Blueprint.Input

  scalar :cursor, name: "Cursor" do
    description """
    An opaque position marker for pagination. Paginated queries return
    a PageInfo struct with start and end cursors (which are actually
    lists of Cursor for ...reasons...). You can then issue queries
    requesting results `before` the `start` or `after` the `end`
    cursors to request the previous or next page respectively.

    Is actually a string or integer. May be extended in future.
    """
    serialize &encode/1
    parse &decode/1
  end

  @spec decode(Input.String.t) :: {:ok, binary}
  @spec decode(Input.Integer.t) :: {:ok, integer}
  @spec decode(term) :: {:error, :bad_parse}
  defp decode(%Input.String{value: value}=s) do
    IO.inspect(string: s)
    {:ok, value}
  end

  defp decode(%Input.Integer{value: value}=i) do
    IO.inspect(integer: i)
    {:ok, value}
  end

  defp decode(alien) do
    IO.inspect(alien: alien)
    {:error, :bad_parse}
  end

  defp encode(value), do: value

end
