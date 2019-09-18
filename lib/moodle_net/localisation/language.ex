defmodule MoodleNet.Localisation.Language do
  @moduledoc "A language keyed by iso-2 code"
  use MoodleNet.Common.Schema

  standalone_schema "mn_language" do
    field :english_name, :string
    field :local_name, :string
    timestamps()
  end

end
