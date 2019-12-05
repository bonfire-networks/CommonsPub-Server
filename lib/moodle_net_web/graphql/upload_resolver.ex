# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.UploadResolver do
  alias Ecto.Changeset
  alias MoodleNet.{GraphQL, Uploads, Users, Meta, Repo}
  alias MoodleNet.Uploads.Upload

  def upload(params, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user(info),
           {:ok, parent} <- Meta.find(params.context_id),
           parent = Meta.follow!(parent),
           {:ok, upload} <- Uploads.upload(parent, user, params.upload, params) do
        # TODO: move me
        parent
        |> Changeset.cast(%{}, [])
        # FIXME: put ID instead
        |> Changeset.put_change(params.field_type, upload.url)
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

  defp pick_uploader(:icon), do: MoodleNet.Uploads.IconUploader
  defp pick_uploader(:image), do: MoodleNet.Uploads.ImageUploader
end
