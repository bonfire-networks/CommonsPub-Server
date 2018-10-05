defmodule ActivityStream do
  alias ActivityStream.{IRI, Object}

  alias Pleroma.Repo

  @doc """
  Returns true if the given argument is a valid ActivityStream IRI,
  otherwise, returns false.

  ## Examples

      iex> ActivityStream.valid_iri?(nil)
      false

      iex> ActivityStream.valid_iri?("https://social.example/")
      false

      iex> ActivityStream.valid_iri?("https://social.example/alyssa/")
      true
  """
  @spec valid_iri?(String.t) :: boolean
  def valid_iri?(iri), do: validate_iri(iri) == :ok

  @doc """
  Verifies the given argument is an ActivityStream valid IRI
  and returns the reason if not.

  ## Examples

      iex> ActivityStream.validate_iri(nil)
      {:error, :not_string}

      iex> ActivityStream.validate_iri("social.example")
      {:error, :invalid_scheme}

      iex> ActivityStream.validate_iri("https://")
      {:error, :invalid_host}

      iex> ActivityStream.validate_iri("https://social.example/")
      {:error, :invalid_path}

      iex> ActivityStream.validate_iri("https://social.example/alyssa")
      :ok
  """
  @spec validate_iri(String.t) :: :ok | {:error, :invalid_scheme} | {:error, :invalid_host} | {:error, :invalid_path} | {:error, :not_string}
  def validate_iri(iri), do: IRI.validate(iri)

  def is_local?(iri) do
    true
  end

  @doc """
  Returns an object given and ID.

  Options:
    * `:cache` when is `true`, it uses cache to try to get the object.
      This is the first option.
      Default value is `true`.
    * `:database` when is `true`, it uses the database like second option get the object.
      This is the second option, so it is only used when cache is disabled or it couldn't be found.
      Default value is `true`.
    * `:external` when is `true`, it makes a request to an external server to get the object.
      This is the third option, so it is only used when the database is disabled or it couldn't be found.
      Default value is `true`.
  """
  @spec get_object(binary, map | Keyword.t) :: {:ok, Object.t} | {:error, :not_found} | {:error, :invalid_id}
  def get_object(id, opts \\ %{cache: true, database: true, external: true})
  def get_object(id, opts) do
  end

  def create_object(params) do
    Object.changeset(%Object{}, params)
    |> Repo.insert()
  end

  def update_object(%Object{} = object, params) do
    Object.changeset(object, params)
    |> Repo.update()
  end
end
