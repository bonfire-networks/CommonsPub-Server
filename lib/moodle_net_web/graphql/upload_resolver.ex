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
    with {:ok, _} <- current_actor(info) do
      do_upload(Avatar, :icon, params)
    end
  end

  def upload_image(params, info) do
    with {:ok, _} <- current_actor(info) do
      do_upload(Background, :image, params)
    end
  end

  defp do_upload(uploader, field_name, %{local_id: local_id, image: image}) do
    with {:ok, object} <- fetch_object_by_id(local_id),
         image_object = fetch_image_field(object, field_name),
         {:ok, url} <- uploader.store(image),
         {:ok, _} <- ActivityPub.update(object, url: url),
      do: {:ok, url}
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
