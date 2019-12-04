defmodule MoodleNet.Localisation.Language do
  @moduledoc "A language keyed by iso-2 code"
  use MoodleNet.Common.Schema

  table_schema "mn_language" do
    field(:iso_code2, :string)
    field(:iso_code3, :string)
    field(:english_name, :string)
    field(:local_name, :string)
    field(:deleted_at, :utc_datetime_usec)
    field(:published_at, :utc_datetime_usec)
    timestamps()
  end
end
