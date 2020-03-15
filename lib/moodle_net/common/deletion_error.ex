# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.DeletionError do
  @enforce_keys [:message, :code, :status]
  defstruct @enforce_keys

  alias Ecto.Changeset
  alias MoodleNet.Common.DeletionError

  @type t :: %__MODULE__{
    message: binary,
    code: binary,
    status: integer
  }

  @spec new(term) :: t
  @doc "Create a new DeletionError"
  def new(%Changeset{} = changeset) do
    {_key, {message, _args}} = changeset.errors |> List.first()
    new(message)
  end

  def new(message) when is_binary(message) do
    %DeletionError{
      message: message,
      code: "deletion_error",
      status: 400,
    }
  end
end
