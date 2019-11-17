# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.Upload do
  use MoodleNet.Common.Schema
  import MoodleNet.Common.Changeset, only: [change_public: 1]

  alias Ecto.Changeset
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Users.User

  @type t :: %__MODULE__{}

  standalone_schema "mn_upload" do
    # has_one(:preview, __MODULE__)
    belongs_to(:parent, Pointer)
    belongs_to(:uploader, User)
    field(:path, :string)
    field(:size, :integer)
    field(:media_type, :string)
    field(:metadata, :map)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps()
  end

  @create_cast ~w(path size media_type metadata is_public)a
  @create_required ~w(path size media_type is_public)a

  def create_changeset(parent, %User{} = uploader, attrs) do
    %__MODULE__{}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> Changeset.change(
      parent_id: parent.id,
      uploader_id: uploader.id
    )
    |> change_public()
  end

  def soft_delete_changeset(%__MODULE__{} = upload) do
    MoodleNet.Common.Changeset.soft_delete_changeset(upload)
  end
end
