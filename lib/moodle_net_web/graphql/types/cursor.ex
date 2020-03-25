# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.Cursor do
  defstruct [data: nil, normalized: nil, raw: nil, errors: [], flags: %{}]

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.Cursor

  scalar :cursor, name: "Cursor" do
    description """
    Used for pagination. Is actually a string, integer or list of string and/or integer
    """
    serialize &encode/1
    parse &decode/1
  end

  # def validate_one(%Absinthe.Blueprint.Input.String{value: value}), do: true
  # def validate_one(%Absinthe.Blueprint.Input.Integer{value: value}), do: true
  # def validate_one(%Absinthe.Blueprint.Input.Null{}), do: true
  # def validate_one(other) do
  #   IO.inspect(other: other)
  #   false
  # end

  def validate(x) do
    # IO.inspect(validate: x)
    true
  end

  # def validate(many) when is_list(many) do
  #   IO.inspect(many: many)
  #   Enum.all?(many, &validate_one/1)
  # end
  # def validate(%Absinthe.Blueprint.Input.Variable{}) do
  #   IO.inspect(:variable)
  #   true
  # end
  # def validate(one), do: validate_one(one)

  defp decode(input) do
    if validate(input), do: {:ok, input}, else: {:error, :invalid_cursor}
  end

  defp encode(value), do: value

end
