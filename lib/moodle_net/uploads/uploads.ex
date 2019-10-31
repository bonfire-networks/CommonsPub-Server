# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads do
  alias Ecto.Changeset
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Uploads.{Upload, Storage}
  alias MoodleNet.Repo

  @doc """
  Attempt to retrieve an upload by its ID.
  """
  @spec fetch(id :: binary) :: {:ok, Upload.t()} | {:error, Changeset.t()}
  def fetch(id), do: Repo.fetch(Upload, id)

  @doc """
  Attempt to retrieve an upload by its storage path.
  """
  @spec fetch_by_path(path :: binary) :: {:ok, Upload.t()} | {:error, Changeset.t()}
  def fetch_by_path(path), do: Repo.fetch_by(Upload, path: path)

  @doc """
  Attempt to store a file, returning an upload, for any parent item that
  participates in the meta abstraction, providing the actor responsible for
  the upload.
  """
  @spec upload(parent :: any, uploader :: Actor.t(), file :: any, attrs :: map) ::
          {:ok, Upload.t()} | {:error, Changeset.t()}
  def upload(parent, uploader, file, attrs) do
    # TODO: extract metadata, pass to attrs
    with {:ok, file_info} <- Storage.store(file) do
      attrs =
        attrs
        |> Map.put(:path, file_info.identifier)
        |> Map.put(:size, file_info.size)

      # FIXME: rollback file store if insert fails
      Repo.insert(Upload.create_changeset(parent, uploader, attrs))
    end
  end

  @doc """
  Attempt to fetch a remotely accessible URL for the associated file in an upload.
  """
  def remote_url(%Upload{} = upload), do: Storage.remote_url(upload.path)

  @doc """
  Delete an upload, removing it from indexing, but the files remain available.
  """
  @spec soft_delete(Upload.t()) :: {:ok, Upload.t()} | {:error, Changeset.t()}
  def soft_delete(%Upload{} = upload) do
    upload
    |> Upload.soft_delete_changeset()
    |> Repo.update()
  end

  @doc """
  Delete an upload, removing any associated files.
  """
  @spec hard_delete(Upload.t()) :: :ok | {:error, Changeset.t()}
  def hard_delete(%Upload{} = upload) do
    # TODO: handle return file errors
    Repo.transact_with(fn ->
      with {:ok, upload} <- Repo.delete(upload),
           do: Storage.delete(upload.path)
    end)
  end
end
