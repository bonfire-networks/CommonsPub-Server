defmodule MoodleNet.Localisation.Language do
  @moduledoc "A language keyed by iso-2 code"
  use MoodleNet.Common.Schema

  @primary_key {:id, :string, autogenerate: false}
  @timestamps_opts [type: :utc_datetime_usec]
  schema "mn_language" do
    field :english_name, :string
    field :local_name, :string
    timestamps(updated_at: false)
  end
end
