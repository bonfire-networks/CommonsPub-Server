# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.UploadResolver do
  import MoodleNetWeb.GraphQL.MoodleNetSchema
  alias ActivityPub.SQL.Query
  alias MoodleNetWeb.Uploaders.{Avatar, Background}

  def upload_icon(params, info) do
    # FIXME: this isn't authorization
    with {:ok, _} <- current_actor(info),
         {:ok, object} <- fetch_object_by_id(params.local_id),
         image_object = fetch_image_field(object, :icon),
         {:ok, ref_url} <- Avatar.store({params.image, params.local_id}) do
      %{full: original_url, thumbnail: thumbnail_url} =
        Avatar.urls({ref_url, params.local_id})

      with {:ok, _} <- ActivityPub.update(image_object, url: original_url),
           {:ok, preview_object} <- update_preview(image_object, thumbnail_url),
        do: {:ok, original_url}
    end
  end

  def upload_image(params, info) do
    with {:ok, object} <- fetch_object_by_id(params.local_id),
         image_object = fetch_image_field(object, :image),
         {:ok, ref_url} <- Background.store({params.image, params.local_id}),
         url = Background.url({ref_url, params.local_id}),
         {:ok, _} <- ActivityPub.update(image_object, url: url),
      do: {:ok, url}
  end

  defp update_preview(object, url) do
    case fetch_image_field(object, :preview) do
      nil ->
        params = [type: "Image", url: url, media_type: "TODO"]
        with {:ok, preview} <- ActivityPub.new(params),
             {:ok, preview} <- ActivityPub.insert(preview),
             {:ok, _} <- ActivityPub.SQL.Alter.add(object, :preview, preview),
          do: {:ok, preview}

      preview ->
        ActivityPub.update(preview, [url: url, media_type: "TODO"])
    end
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
