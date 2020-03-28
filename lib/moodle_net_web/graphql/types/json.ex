# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.JSON do
  @moduledoc """
  The Json scalar type allows arbitrary JSON values to be passed in and out.
  Requires `{ :jason, "~> 1.1" }` package: https://github.com/michalmuskala/jason
  """
  alias Absinthe.Blueprint.Input
  use Absinthe.Schema.Notation

  scalar :json, name: "Json" do
    description "Arbitrary json stored as a string"
    serialize(&encode/1)
    parse(&decode/1)
  end

  @spec decode(Input.String.t) :: {:ok, term} | {:error, term}
  @spec decode(Input.Null.t) :: {:ok, nil}
  defp decode(%Input.String{value: value}), do: Jason.decode(value)
  defp decode(%Input.Null{}), do: {:ok, nil}
  defp decode(_), do: {:error, :bad_input_type}

  defp encode(value), do: value
end
