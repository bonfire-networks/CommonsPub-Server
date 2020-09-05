# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Uploads.ContentUpload do
  use CommonsPub.Common.Schema

  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  table_schema "mn_content_upload" do
    field(:path, :string)
    field(:size, :integer)
  end

  @cast ~w(path size)a
  @required @cast

  def changeset(attrs) do
    %__MODULE__{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
  end
end
