# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.UploadResolver do
  alias Ecto.Changeset
  alias MoodleNet.{GraphQL, Uploads, Users, Meta, Repo}
  alias MoodleNet.Uploads.Upload

  @allowed_field_names ~w(icon image url)a

  def upload_icon(params, info),
    do: upload(params, info, :icon, MoodleNet.Uploads.IconUploader)

  def upload_image(params, info),
    do: upload(params, info, :image, MoodleNet.Uploads.ImageUploader)

  def upload_resource(params, info),
    do: upload(params, info, :url, MoodleNet.Uploads.ResourceUploader)

  defp upload(params, info, field_name, upload_def) when is_atom(field_name) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user(info),
           {:ok, parent} <- Meta.find(params.context_id),
           parent = Meta.follow!(parent),
           {:ok, upload} <- Uploads.upload(upload_def, parent, user, params.upload, params) do
        # TODO: move me
        parent
        |> Changeset.cast(%{}, [])
        # FIXME: put ID instead
        |> Changeset.put_change(field_name, upload.url)
        |> Repo.update()

        {:ok, upload}
      end
    end)
  end

  def is_public(%Upload{}=upload, _, info), do: not is_nil(upload.published_at)

  def parent(%Upload{}=upload, _, info) do
    with {:ok, pointer} <- Meta.find(upload), do: Meta.follow(pointer)
  end

  def uploader(%Upload{}=upload, _, info), do: Users.fetch(upload)
end
