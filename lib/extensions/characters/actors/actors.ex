defmodule CommonsPub.Actors do
  @doc """
  A deprecated context for dealing with Actors (use character instead)

  Actors come in several kinds:
  * Users
  * Communities
  * Collections
  """

  alias CommonsPub.Actors.{Actor, NameReservation, Queries}
  alias CommonsPub.Repo
  alias CommonsPub.Users.User
  alias Ecto.Changeset

  def one(filters), do: Repo.single(Queries.query(Actor, filters))

  @doc "creates a new actor from the given attrs"
  @spec create(attrs :: map) :: {:ok, Actor.t()} | {:error, Changeset.t()}
  def create(attrs) when is_map(attrs) do
    # attrs = Map.put(attrs, :preferred_username, atomise_username(Map.get(attrs, :preferred_username)))
    Repo.transact_with(fn ->
      with {:ok, actor} <- Repo.insert(Actor.create_changeset(attrs)) do
        if is_nil(actor.peer_id) do
          case CommonsPub.Character.Characters.reserve_username(attrs.preferred_username) do
            {:ok, _} -> {:ok, actor}
            _ -> {:error, "Username already taken"}
          end
        else
          {:ok, actor}
        end
      end
    end)
  end

  @spec update(user :: User.t(), actor :: Actor.t(), attrs :: map) ::
          {:ok, Actor.t()} | {:error, Changeset.t()}
  def update(%User{}, %Actor{} = actor, attrs) when is_map(attrs) do
    Repo.update(Actor.update_changeset(actor, attrs))
  end

  def update(_, actor, _) do
    # FIXME
    actor
  end

  @spec delete(user :: User.t(), actor :: Actor.t()) :: {:ok, Actor.t()} | {:error, term}
  def delete(%User{}, %Actor{} = actor), do: Repo.delete(actor)
end
