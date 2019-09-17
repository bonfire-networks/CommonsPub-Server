defmodule MoodleNet.Comments.Comment do

  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key :binary_id
  @timestamps_opts [type: :utc_datetime_usec]
  schema "mn_comment" do
  end

end
