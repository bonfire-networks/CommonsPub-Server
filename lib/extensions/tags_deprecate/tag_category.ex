# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Common.TagCategory do
  use CommonsPub.Repo.Schema

  table_schema "mn_tag_category" do
    field(:canonical_url, :string)
    field(:name, :string)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps(inserted_at: :created_at)
  end
end
