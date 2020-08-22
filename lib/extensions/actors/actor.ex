# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Actors.Actor do
  use MoodleNet.Common.Schema
  alias Ecto.Changeset
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Peers.Peer
  alias MoodleNet.Users.User

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
    |> validate_username()
    |> cast_url()
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

  defp validate_username(changeset) do
    Changeset.validate_format(changeset, :preferred_username, username_regex(is_local(changeset)))
  end

  defp cast_url(changeset) do
    cast_url(changeset, Changeset.get_field(changeset, :canonical_url))
  end

  defp cast_url(cs, x) when not is_nil(x), do: cs

  defp cast_url(cs, _) do
    name = Changeset.get_field(cs, :preferred_username)
    url = ActivityPub.Utils.actor_url(%{preferred_username: "#{name}"})
    Changeset.put_change(cs, :canonical_url, url)
  end

  defp username_regex(true), do: @local_username_regex
  defp username_regex(false), do: @remote_username_regex

  defp is_local(changeset), do: is_nil(Changeset.fetch_field(changeset, :peer_id))
end
