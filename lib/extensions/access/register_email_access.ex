# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Access.RegisterEmailAccess do
  @moduledoc """
  A simple standalone schema listing email addresses which are
  permitted to register a CommonsPub account while public signup is
  disabled.
  """
  use CommonsPub.Common.Schema
  import CommonsPub.Common.Changeset, only: [validate_email: 2]
  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  table_schema "mn_access_register_email" do
    field(:email, :string, primary_key: true)
    timestamps()
  end

  @create_cast ~w(email)a
  @create_required @create_cast

  def create_changeset(fields) do
    %__MODULE__{}
    |> Changeset.cast(fields, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> validate_email(:email)
    |> Changeset.unique_constraint(:email, name: "mn_access_register_email_email_index")
  end
end
