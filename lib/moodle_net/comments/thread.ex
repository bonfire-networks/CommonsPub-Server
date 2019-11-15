defmodule MoodleNet.Comments.Thread do
  use MoodleNet.Common.Schema
  import MoodleNet.Common.Changeset, only: [change_public: 1]
  alias Ecto.Changeset
  alias MoodleNet.Comments.Thread
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Users.User

  meta_schema "mn_thread" do
    belongs_to(:creator, User)
    belongs_to(:context, Pointer)
    field(:canonical_url, :string)
    field(:is_locked, :boolean, virtual: true)
    field(:locked_at, :utc_datetime_usec)
    field(:is_hidden, :boolean, virtual: true)
    field(:hidden_at, :utc_datetime_usec)
    field(:is_local, :boolean)
    timestamps()
  end

  @create_cast ~w(canonical_url is_locked is_hidden is_local)a
  @create_required @create_cast

  def create_changeset(%Pointer{id: id} = pointer, %Pointer{} = context, %User{} = creator, attrs) do
    Meta.assert_points_to!(pointer, __MODULE__)

    %Thread{}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.change(
      id: id,
      creator_id: creator.id,
      context_id: context.id
    )
    |> Changeset.validate_required(@create_required)
    |> change_public()
  end

  @update_cast @create_cast

  def update_changeset(%Thread{} = thread, attrs) do
    thread
    |> Changeset.cast(attrs, @update_cast)
    |> change_public()
  end
end
