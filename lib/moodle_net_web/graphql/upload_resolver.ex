# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.UploadResolver do
  alias Ecto.Changeset
  alias MoodleNet.{GraphQL, Uploads, Users, Repo}
  alias MoodleNet.Meta.Pointers
  alias MoodleNet.Uploads.Content

  def upload(%{icon: params}, info) do
    do_upload(params, info, :icon_id, MoodleNet.Uploads.IconUploader)
  end

  def upload(%{image: params}, info) do
    do_upload(params, info, :image_id, MoodleNet.Uploads.ImageUploader)
  end

  def upload(%{content: params}, info) do
    do_upload(params, info, :content_id, MoodleNet.Uploads.ResourceUploader)
  end

  defp do_upload(params, info, field_name, upload_def) when is_atom(field_name) do
    user = GraphQL.current_user(info)
    with {:ok, parent_ptr} <- Pointers.one(id: params.context_id),
          parent = Pointers.follow!(parent_ptr),
          {:ok, upload} <- Uploads.upload(upload_def, user, params.upload, params),
          {:ok, _parent} <- update_parent_field(parent, field_name, upload) do
      {:ok, upload}
    end
  end

  def icon_content_edge(%{icon_id: id}, _, info), do: content_edge(id)
  def image_content_edge(%{image_id: id}, _, info), do: content_edge(id)
  def resource_content_edge(%{content_id: id}, _, info), do: content_edge(id)

  defp content_edge(id), do: Uploads.one([:deleted, :private, id: id])

  def is_public(%Content{}=upload, _, _info), do: {:ok, not is_nil(upload.published_at)}

  def uploader(%Content{uploader_id: id}, _, _info), do: Users.one(id: id)

  def remote_url(%Content{}=upload, _, _info), do: Uploads.remote_url(upload)

  def content_upload(%Content{content_upload: upload}, _, _info), do: {:ok, upload}
  def content_mirror(%Content{content_mirror: mirror}, _, _info), do: {:ok, mirror}

  defp update_parent_field(parent, field_name, %Content{id: id} = content) do
    parent
    |> Changeset.cast(%{}, [])
    |> Changeset.put_change(field_name, id)
    |> Repo.update()
  end
end
