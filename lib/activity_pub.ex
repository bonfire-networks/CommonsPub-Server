defmodule ActivityPub do

  defdelegate new(params), to: ActivityPub.Builder
  defdelegate insert(params), to: ActivityPub.SQLEntity
  defdelegate get_by_local_id(params), to: ActivityPub.SQLEntity
  defdelegate get_by_id(params), to: ActivityPub.SQLEntity
  defdelegate reload(params), to: ActivityPub.SQL.Query

  # @doc """
  # Returns true if the given argument is a valid ActivityPub IRI,
  # otherwise, returns false.

  # ## Examples

  #     iex> ActivityPub.valid_iri?(nil)
  #     false

  #     iex> ActivityPub.valid_iri?("https://social.example/")
  #     true

  #     iex> ActivityPub.valid_iri?("https://social.example/alyssa/")
  #     true
  # """
  # @spec valid_iri?(String.t()) :: boolean
  # def valid_iri?(iri), do: validate_iri(iri) == :ok

  # @doc """
  # Verifies the given argument is an ActivityPub valid IRI
  # and returns the reason if not.

  # ## Examples

  #     iex> ActivityPub.validate_iri(nil)
  #     {:error, :not_string}

  #     iex> ActivityPub.validate_iri("social.example")
  #     {:error, :invalid_scheme}

  #     iex> ActivityPub.validate_iri("https://")
  #     {:error, :invalid_host}

  #     iex> ActivityPub.validate_iri("https://social.example/alyssa")
  #     :ok
  # """
  # @spec validate_iri(String.t()) ::
  #         :ok
  #         | {:error, :invalid_scheme}
  #         | {:error, :invalid_host}
  #         | {:error, :not_string}
  # def validate_iri(iri), do: IRI.validate(iri)

  # alias ActivityPub.Actor
  # alias Ecto.Multi

  # def create_actor(multi, params, opts \\ []) do
  #   key = Keyword.get(opts, :key, :actor)
  #   pre_key = String.to_atom("_pre_#{key}")

  #   multi
  #   |> Multi.insert(pre_key, Actor.create_local_changeset(params))
  #   |> Multi.run(key, &(Actor.set_uris(&2[pre_key]) |> &1.update()))
  # end

  # def get_actor!(id) do
  #   Repo.get!(Actor, id)
  # end

  # def follow(multi, follower, following, opts \\ []) do
  #   key = Keyword.get(opts, :key, :follow)
  #   ch = ActivityPub.Follow.create_changeset(follower, following)

  #   Multi.insert(multi, key, ch,
  #     returning: true,
  #     conflict_target: [:follower_id, :following_id],
  #     on_conflict: {:replace, [:follower_id]}
  #   )
  # end

  # def unfollow(multi, follower, following, opts \\ []) do
  #   key = Keyword.get(opts, :key, :unfollow)
  #   query = ActivityPub.Follow.delete_query(follower, following)
  #   Multi.delete_all(multi, key, query)
  # end

  # @doc """
  # Returns an object given and ID.

  # Options:
  #   * `:cache` when is `true`, it uses cache to try to get the object.
  #     This is the first option.
  #     Default value is `true`.
  #   * `:database` when is `true`, it uses the database like second option get the object.
  #     This is the second option, so it is only used when cache is disabled or it couldn't be found.
  #     Default value is `true`.
  #   * `:external` when is `true`, it makes a request to an external server to get the object.
  #     This is the third option, so it is only used when the database is disabled or it couldn't be found.
  #     Default value is `true`.
  # """
  # @spec get_object(binary, map | Keyword.t()) ::
  #         {:ok, Object.t()} | {:error, :not_found} | {:error, :invalid_id}
  # def get_object(id, opts \\ %{cache: true, database: true, external: true})
end
