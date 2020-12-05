# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Uploads.ContentMirror do
  use CommonsPub.Repo.Schema

  import CommonsPub.Repo.Changeset, only: [validate_http_url: 2]
  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  table_schema "mn_content_mirror" do
    field(:url, :string)
  end

  @cast ~w(url)a
  @required @cast

  def changeset(attrs) do
    %__MODULE__{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.validate_length(:url, max: 4096)
    |> validate_http_url(:url)
  end
end
