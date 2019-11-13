defmodule MoodleNet.Activities.Activity do
  use MoodleNet.Common.Schema

  alias MoodleNet.Users.User

  meta_schema "mn_activity" do
    belongs_to(:user, User)
    belongs_to(:context, Pointer)
    field(:canonical_url, :string)
    field(:verb, :string)
    field(:is_local, :boolean)
    field(:published_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps(inserted_at: :created_at)
  end
end
