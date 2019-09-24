defmodule MoodleNet.Localisation.Country do
  @moduledoc "A country keyed by iso-2 code"
  use MoodleNet.Common.Schema

  @primary_key {:id, :string, autogenerate: false}
  @timestamps_opts [type: :utc_datetime_usec]
  schema "mn_country" do
    field :english_name, :string
    field :local_name, :string
    timestamps(updated_at: false)
  end
end
