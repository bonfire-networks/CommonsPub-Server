# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.UploadResolver do
  import MoodleNetWeb.GraphQL.MoodleNetSchema
  alias ActivityPub.SQL.Query

  alias MoodleNetWeb.Uploader
  alias MoodleNetWeb.Uploaders.{Avatar, Background}

  def upload_icon(params, info) do
    # FIXME: this isn't authorization
    with {:ok, _} <- current_actor(info),
         {:ok, object} <- fetch_object_by_id(params.local_id),
         image_object = fetch_image_field(object, :icon),
         {:ok, uploads} <- Uploader.store(Avatar, params.image, params.local_id) do
      params = upload_to_icon(uploads.full)
      with {:ok, _} <- ActivityPub.update(image_object, params),
           {:ok, preview_object} <- update_preview(image_object, uploads.thumbnail),
           do: {:ok, params.url}
    end
  end

  def upload_image(params, info) do
    with {:ok, object} <- fetch_object_by_id(params.local_id),
         image_object = fetch_image_field(object, :image),
         {:ok, uploads} <- Uploader.store(Background, params.image, params.local_id),
         {:ok, _} <- ActivityPub.update(image_object, upload_to_icon(uploads.full)),
         do: {:ok, uploads.full.url}
  end

  defp update_preview(object, upload) do
    params = upload_to_icon(upload)
    case fetch_image_field(object, :preview) do
      nil ->
        with {:ok, preview} <- ActivityPub.new(params),
             {:ok, preview} <- ActivityPub.insert(preview),
             {:ok, _} <- ActivityPub.SQL.Alter.add(object, :preview, preview),
             do: {:ok, preview}

      preview ->
        ActivityPub.update(preview, params)
    end
  end

  defp upload_to_icon(upload) do
    %{
      type: "Image",
      url: upload.url,
      media_type: upload.media_type,
      width: upload.metadata.width_px,
      height: upload.metadata.height_px
    }
  end

  defp fetch_object_by_id(local_id) do
    case fetch(local_id, "Object") do
      # TODO: move this to fetch/2
      {:ok, nil} -> {:error, :not_found}
      {:ok, object} -> {:ok, object}
      error -> error
    end
  end

  defp fetch_image_field(object, field_name) do
    Query.new()
    |> Query.belongs_to(field_name, object)
    |> Query.one()
  end
end
