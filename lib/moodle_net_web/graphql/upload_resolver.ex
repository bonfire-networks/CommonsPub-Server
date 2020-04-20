# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.UploadResolver do
  alias Ecto.Changeset
  alias MoodleNet.{GraphQL, Uploads, Users, Repo}
  alias MoodleNet.Meta.Pointers
  alias MoodleNet.Uploads.Content

  @uploader_fields %{
    content: MoodleNet.Uploads.ResourceUploader,
    image: MoodleNet.Uploads.ImageUploader,
    icon: MoodleNet.Uploads.IconUploader
  }

  def upload(%{} = params, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
      params
      |> Enum.reduce_while(%{}, &(do_upload(user, &1, &2)))
      |> case do
        {:error, _} = e -> e
        val -> {:ok, Enum.into(val, %{})}
      end
    end
  end

  defp do_upload(user, {field_name, content_input}, acc) do
    uploader = @uploader_fields[field_name]

    if uploader do
      case Uploads.upload(uploader, user, content_input, %{}) do
        {:ok, content} ->
          field_id_name = String.to_existing_atom("#{field_name}_id")

          {:cont, Map.put(acc, field_id_name, content.id)}

        {:error, reason} ->
          # FIXME: delete other successful files on failure
          {:halt, {:error, reason}}
      end
    else
      {:cont, acc}
    end
  end

  def icon_content_edge(%{icon_id: id}, _, info), do: content_edge(id)
  def image_content_edge(%{image_id: id}, _, info), do: content_edge(id)
  def resource_content_edge(%{content_id: id}, _, info), do: content_edge(id)

  defp content_edge(id) when is_binary(id), do: Uploads.one([:deleted, :private, id: id])
  defp content_edge(_), do: GraphQL.not_found()

  def is_public(%Content{} = upload, _, _info), do: {:ok, not is_nil(upload.published_at)}

  def uploader(%Content{uploader_id: id}, _, _info), do: Users.one(id: id)

  def remote_url(%Content{} = upload, _, _info), do: Uploads.remote_url(upload)

  def content_upload(%Content{content_upload: upload}, _, _info), do: {:ok, upload}
  def content_mirror(%Content{content_mirror: mirror}, _, _info), do: {:ok, mirror}
end
