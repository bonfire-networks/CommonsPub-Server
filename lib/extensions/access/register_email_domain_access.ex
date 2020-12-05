# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Access.RegisterEmailDomainAccess do
  @moduledoc """
  A simple standalone schema listing domains for which emails at those
  domains are permitted to register a CommonsPub account while public
  signup is disabled.
  """
  use Bonfire.Repo.Schema
  import Bonfire.Repo.Changeset, only: [validate_email_domain: 2]
  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  table_schema "mn_access_register_email_domain" do
    field(:domain, :string)
    timestamps()
  end

  @create_cast ~w(domain)a
  @create_required @create_cast

  def create_changeset(fields) do
    %__MODULE__{}
    |> Changeset.cast(fields, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> validate_email_domain(:domain)
    |> Changeset.unique_constraint(:domain, name: "mn_access_register_email_domain_domain_index")
  end
end
