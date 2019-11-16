# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Access.RegisterEmailDomainAccess do
  @moduledoc """
  A simple standalone schema listing domains for which emails at those
  domains are permitted to register a MoodleNet account while public
  signup is disabled.
  """
  use MoodleNet.Common.Schema
  import MoodleNet.Common.Changeset, only: [validate_email_domain: 2, meta_pointer_constraint: 1]
  alias Ecto.Changeset
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer

  @type t :: %__MODULE__{}

  meta_schema "mn_access_register_email_domain" do
    field(:domain, :string)
    timestamps(inserted_at: :created_at)
  end

  @create_cast ~w(domain)a
  @create_required @create_cast

  def create_changeset(%Pointer{id: id} = pointer, fields) do
    Meta.assert_points_to!(pointer, __MODULE__)

    %__MODULE__{id: id}
    |> Changeset.cast(fields, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> validate_email_domain(:domain)
    |> Changeset.unique_constraint(:domain,
      name: "mn_access_register_email_domain"
    )
    |> meta_pointer_constraint()
  end
end
