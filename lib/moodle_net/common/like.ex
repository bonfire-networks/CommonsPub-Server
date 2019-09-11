defmodule MoodleNet.Common.Like do

  use Ecto.Schema
  alias MoodleNet.Common.Flag
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Communities.Community

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  schema "mn_like" do
    belongs_to :liked, Pointer
    belongs_to :liker, Actor
    timestamps()
  end

  @create_cast ~w(liked_id liker_id)a
  @create_required @create_cast
  def create_changeset(id, attrs) do
    %Flag{id: id}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> Changeset.foreign_key_constraint(:id)
    |> Changeset.foreign_key_constraint(:liked_id)
    |> Changeset.foreign_key_constraint(:liker_id)
  end

end
