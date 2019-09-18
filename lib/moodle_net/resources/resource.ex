defmodule MoodleNet.Resources.Resource do

  use MoodleNet.Common.Schema
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Localisation.Language

  meta_schema "mn_resource" do
    belongs_to :creator, Actor
    belongs_to :collection, Collection
    belongs_to :primary_language, Language
    field :published_at, :utc_datetime_usec
    field :deleted_at, :utc_datetime_usec
    timestamps()
  end

end
