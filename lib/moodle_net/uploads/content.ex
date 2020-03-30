# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads.Content do
  use MoodleNet.Common.Schema
  import MoodleNet.Common.Changeset, only: [change_public: 1]

  alias Ecto.Changeset
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Users.User
  alias MoodleNet.Uploads.{ContentRemote, ContentUpload}

  @type t :: %__MODULE__{}

  table_schema "mn_content" do
    # has_one(:preview, __MODULE__)
    belongs_to(:uploader, User)
    has_one(:content_upload, ContentUpload)
    has_one(:content_remote, ContentRemote)
    field(:size, :integer)
    field(:media_type, :string)
    field(:metadata, :map)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps(inserted_at: :created_at)
  end

  @create_cast ~w(size media_type metadata is_public)a
  @create_required ~w(size media_type)a

  def create_changeset(%User{} = uploader, attrs) do
    %__MODULE__{}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> Changeset.change(
      is_public: true,
      uploader_id: uploader.id
    )
    |> change_public()
  end
end
