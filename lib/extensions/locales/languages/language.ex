# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Locales.Language do
  use Ecto.Schema

  # alias Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :string, autogenerate: false}
  schema "languages" do
    # field(:id, :string)
    field(:iso639_1, :string)

    field(:main_name, :string)
    field(:sub_name, :string)
    field(:native_name, :string)

    field(:language_type, :string)

    # field(:parent_language_id, :string)
    belongs_to(:parent_language, CommonsPub.Locales.Language, type: :string)

    # field(:main_country_id, :string)
    belongs_to(:main_country, CommonsPub.Locales.Country, type: :string)

    field(:speakers_mil, :float)
    field(:speakers_native, :integer)
    field(:speakers_native_total, :integer)

    field(:rtl, :boolean)
  end
end
