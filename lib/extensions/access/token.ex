# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Access.Token do
  @moduledoc "A session token identified by its uuid id"

  use MoodleNet.Common.Schema
  alias MoodleNet.Users.User
  alias __MODULE__
  alias Ecto.Changeset

  # two weeks, in seconds
  @default_validity 3600 * 24 * 14

  uuidv4_schema "access_token" do
    field(:expires_at, :utc_datetime_usec)
    belongs_to(:user, User)
    timestamps()
  end

  def create_changeset(%User{id: user_id}, validity \\ @default_validity) do
    %Token{}
    |> Changeset.cast(%{}, [])
    |> Changeset.change(
      user_id: user_id,
      expires_at: expires_at(validity)
    )
  end

  defp expires_at(validity),
    do: DateTime.add(DateTime.utc_now(), validity)
end
