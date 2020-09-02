# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Actors.Actor do
  @doc """
  A deprecated schema for actor (use character instead)
  """

  use CommonsPub.Common.Schema
  alias Ecto.Changeset
  alias CommonsPub.Actors.Actor
  alias CommonsPub.Collections.Collection
  alias CommonsPub.Communities.Community
  alias CommonsPub.Peers.Peer
  alias CommonsPub.Users.User

  # # TODO: match the agreed rules
  @remote_username_regex ~r(^[a-zA-Z0-9@._-]+$)
  @local_username_regex ~r/^[a-zA-Z][a-zA-Z0-9-]{2,}$/

  table_schema "mn_actor" do
    belongs_to(:peer, Peer)
    has_one(:user, User)
    has_one(:community, Community)
    has_one(:collection, Collection)
    # has_one :following_count, ActorFollowingCount
    field(:preferred_username, :string)
    field(:canonical_url, :string)
    field(:signing_key, :string)
    timestamps()
  end

  @required ~w(preferred_username)a
  @create_cast @required ++ ~w(peer_id canonical_url signing_key)a
  @update_cast ~w(peer_id canonical_url signing_key)a

  @spec create_changeset(map) :: Changeset.t()
  @doc "Creates a changeset for insertion from the given pointer and attrs"
  def create_changeset(attrs) do
    %Actor{}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.validate_required(@required)
    |> CommonsPub.Character.validate_username()
    |> CommonsPub.Character.cast_url()
    # with peer
    |> Changeset.unique_constraint(:preferred_username,
      name: "mn_actor_preferred_username_peer_id_index"
    )
    # without peer (local)
    |> Changeset.unique_constraint(:preferred_username,
      name: "mn_actor_peer_id_null_index"
    )
  end

  @spec update_changeset(%Actor{}, map) :: Changeset.t()
  @doc "Creates a changeset for updating the given actor from the given attrs"
  def update_changeset(%Actor{} = actor, attrs) do
    Changeset.cast(actor, attrs, @update_cast)
  end
end
