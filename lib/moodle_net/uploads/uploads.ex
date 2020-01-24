# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Uploads do

  alias Ecto.Changeset
  alias MoodleNet.Meta.Pointers
  alias MoodleNet.Repo
  alias MoodleNet.Users.User
  alias MoodleNet.Uploads.{Upload, Storage, Queries}

  @doc """
  Return a list of uploads associated with any parent, assuming it is a pointer.
  """
  @spec list_by_parent(parent :: any) :: [Upload.t()]
  def list_by_parent(%{id: id} = _parent), do: Repo.all(list_by_parent_q(id))

  defp list_by_parent_q(id) do
    Queries.query(Upload, [:private, :deleted, parent_id: id])
  end

  @spec list_by_uploader(User.t()) :: [Upload.t()]
  def list_by_uploader(%User{id: id}), do: Repo.all(list_by_uploader_q(id))

  defp list_by_uploader_q(id) do
    Queries.query(Upload, [:private, :deleted, uploader_id: id])
  end

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
  @spec upload(upload_def :: any, parent :: any, uploader :: User.t(), file :: any, attrs :: map) ::
          {:ok, Upload.t()} | {:error, Changeset.t()}
  def upload(upload_def, %{id: _id} = parent, %User{} = uploader, file, attrs) do
    storage_opts = [scope: parent.id]

    with {:ok, file_info} <- Storage.store(upload_def, file, storage_opts) do
      attrs =
        attrs
        |> Map.put(:path, file_info.id)
        |> Map.put(:media_type, file_info.media_type)
        |> Map.put(:size, file_info.info.size)
        |> Map.put(:metadata, file_info.metadata)

      result =
        Repo.transact_with(fn ->
          with {:ok, pointer} <- Pointers.one(id: parent.id) do
            Repo.insert(Upload.create_changeset(pointer, uploader, attrs))
          end
        end)

      with {:ok, upload} <- result,
           {:ok, url} <- remote_url(upload) do
        {:ok, %{upload | url: url}}
      else
        e ->
          # rollback file changes on failure
          Storage.delete(file_info.id)
          e
      end
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
    result = Repo.transaction(fn ->
      with {:ok, upload} <- Repo.delete(upload),
          do: Storage.delete(upload.path)
    end)

    with {:ok, _} <- result, do: :ok
  end
end
