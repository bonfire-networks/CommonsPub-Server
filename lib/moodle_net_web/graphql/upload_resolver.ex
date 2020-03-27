# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.UploadResolver do
  alias Ecto.Changeset
  alias MoodleNet.{GraphQL, Uploads, Users, Repo}
  alias MoodleNet.Meta.Pointers
  alias MoodleNet.Uploads.Content

  def upload_icon(params, info),
    do: upload(params, info, :icon_id, MoodleNet.Uploads.IconUploader)

  def upload_image(params, info),
    do: upload(params, info, :image_id, MoodleNet.Uploads.ImageUploader)

  def upload_resource(params, info),
    do: upload(params, info, :content_id, MoodleNet.Uploads.ResourceUploader)

  defp upload(params, info, field_name, upload_def) when is_atom(field_name) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user(info),
           {:ok, parent_ptr} <- Pointers.one(id: params.context_id),
           parent = Pointers.follow!(parent_ptr),
           {:ok, upload} <- Uploads.upload(upload_def, parent, user, params.upload, params),
           {:ok, _parent} <- update_parent_field(parent, field_name, upload) do
        {:ok, upload}
      end
    end)
  end

  def is_public(%Content{}=upload, _, _info), do: not is_nil(upload.published_at)

  def uploader(%Content{uploader_id: id}, _, _info), do: Users.one(id: id)

  defp update_parent_field(parent, field_name, %Content{id: id} = content) do
    parent
    |> Changeset.cast(%{}, [])
    |> Changeset.put_change(field_name, id)
    |> Repo.update()
  end
end
