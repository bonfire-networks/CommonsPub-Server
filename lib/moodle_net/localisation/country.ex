defmodule MoodleNet.Localisation.Country do
  @moduledoc "A country keyed by iso-2 code"
  use MoodleNet.Common.Schema

  standalone_schema "mn_country" do
    field :english_name, :string
    field :local_name, :string
    timestamps()
  end

end
