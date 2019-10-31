defmodule MoodleNet.Uploads do
  alias Ecto.Changeset
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Uploads.Upload
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
  @spec upload(parent :: any, uploader :: Actor.t(), file :: any) ::
          {:ok, Upload.t()} | {:error, Changeset.t()}
  def upload(parent, uploader, file) do
  end

  @doc """
  Attempt to download the associated file in an upload.
  """
  def download(%Upload{} = upload) do
  end

  @doc """
  Delete an upload, removing it from indexing, but the files remain available.
  """
  def soft_delete(%Upload{} = upload) do
    upload
    |> Upload.soft_delete_changeset()
    |> Repo.update()
  end

  @doc """
  Delete an upload, removing any associated files.
  """
  def hard_delete(%Upload{} = upload) do
  end
end
