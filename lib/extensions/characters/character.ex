# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Characters.Character do
  use Pointers.Mixin,
    otp_app: :commons_pub,
    source: "character"

  import(CommonsPub.Repo.Changeset, only: [change_public: 1, change_disabled: 1])

  alias Ecto.Changeset
  # alias CommonsPub.Characters.Character
  alias CommonsPub.Feeds.Feed
  alias CommonsPub.Users.User

  # alias CommonsPub.Uploads.Content
  # alias Pointers.Pointer

  @remote_username_regex ~r(^[a-zA-Z0-9@._-]+$)
  @local_username_regex ~r/^[a-zA-Z][a-zA-Z0-9-]{2,}$/

  @type t :: %__MODULE__{}

  mixin_schema do
    belongs_to(:peer, Peer)

    # references the Actor who plays this Character in the fediverse
    # belongs_to(:actor, Actor)

    # belongs_to(:context, Pointer) # points to the parent Thing of this character

    # field(:characteristic_id, Ecto.ULID) # points to the Thing that this character represents
    # field(:characteristic, :any, virtual: true)
    # belongs_to(:characteristic, Pointer)

    # name for the Thing this character represents (same naming as the singular object module), eg. Organisation, Geolocation, etc
    field(:facet, :string)

    field(:preferred_username, :string)
    field(:canonical_url, :string)
    field(:signing_key, :string)

    belongs_to(:inbox_feed, Feed, foreign_key: :inbox_id)
    belongs_to(:outbox_feed, Feed, foreign_key: :outbox_id)
    # because it's keyed by pointer
    field(:follower_count, :any, virtual: true)

    belongs_to(:creator, User)

    field(:is_public, :boolean, virtual: true)
    field(:is_disabled, :boolean, virtual: true, default: false)

    field(:published_at, :utc_datetime_usec)
    field(:disabled_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    # timestamps()
  end

  @required ~w(id preferred_username canonical_url)a
  @create_cast @required ++ ~w(peer_id facet signing_key inbox_id outbox_id)a
  @update_cast @required ++ ~w(facet signing_key is_disabled)a

  @doc """
  Create a character without a known creator
  """
  def create_changeset(
        nil,
        # %{id: _} = characteristic,
        # %Actor{} = actor,
        attrs
      ) do
    %CommonsPub.Characters.Character{}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.change(
      # characteristic_id: characteristic_pointer_id(attrs),
      # actor_id: actor.id,
      is_public: true
    )
    |> validate_username()
    |> cast_url()
    |> Changeset.validate_required(@required)
    # with peer
    |> Changeset.unique_constraint(:preferred_username,
      name: "character_preferred_username_peer_id_index"
    )
    # without peer (local)
    |> Changeset.unique_constraint(:preferred_username,
      name: "character_peer_id_null_index"
    )
    |> common_changeset()
  end

  @doc """
  Create a character
  """
  def create_changeset(
        %User{} = creator,
        # %{id: _} = characteristic,
        # %Actor{} = actor,
        attrs
      ) do
    %CommonsPub.Characters.Character{}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.change(
      creator_id: creator.id,
      # characteristic_id: characteristic_pointer_id(attrs),
      # actor_id: actor.id,
      is_public: true
    )
    |> validate_username()
    |> cast_url()
    |> Changeset.validate_required(@required)
    # with peer
    |> Changeset.unique_constraint(:preferred_username,
      name: "character_preferred_username_peer_id_index"
    )
    # without peer (local)
    |> Changeset.unique_constraint(:preferred_username,
      name: "character_peer_id_null_index"
    )
    |> common_changeset()
  end

  # def create_changeset(
  #       %User{} = creator,
  #       # %{id: _} = characteristic,
  #       %Actor{} = actor,
  #       %{id: _} = context,
  #       attrs
  #     ) do
  #   %CommonsPub.Characters.Character{}
  #   |> Changeset.cast(attrs, @cast)
  #   |> Changeset.validate_required(@required)
  #   |> Changeset.change(
  #     creator_id: creator.id,
  #     # characteristic_id: characteristic_pointer_id(attrs),
  #     context_id: context.id,
  #     actor_id: actor.id,
  #     is_public: true
  #   )
  #   |> common_changeset()
  # end

  def update_changeset(%CommonsPub.Characters.Character{} = character, attrs) do
    character
    |> Changeset.cast(attrs, @update_cast)
    # |> Changeset.change(
    #   characteristic_id: characteristic_pointer_id(attrs)
    # )
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_disabled()
  end

  # def characteristic_pointer_id(attrs) do
  #   map_a_grandchild(attrs, :characteristic, :pointer_id, :id)
  # end

  # # ugly, feel free to replace
  # def map_a_grandchild(parent, child, grandchild1, grandchild2) do
  #   if(Map.has_key?(parent, child)) do
  #     child_map = Map.get(parent, child)
  #     # IO.inspect(child_map)
  #     Map.get(child_map, grandchild1, Map.get(child_map, grandchild2, nil))
  #   end
  # end

  defp validate_username(changeset) do
    Changeset.validate_format(changeset, :preferred_username, username_regex(is_local(changeset)))
  end

  defp cast_url(changeset) do
    cast_url(changeset, Changeset.get_field(changeset, :canonical_url))
  end

  defp cast_url(cs, canonical_url) when not is_nil(canonical_url), do: cs

  defp cast_url(cs, _) do
    username = Changeset.get_field(cs, :preferred_username)
    url = ActivityPub.Utils.actor_url(%{preferred_username: "#{username}"})
    Changeset.put_change(cs, :canonical_url, url)
  end

  defp username_regex(true), do: @local_username_regex
  defp username_regex(false), do: @remote_username_regex

  defp is_local(changeset), do: is_nil(Changeset.fetch_field(changeset, :peer_id))
end
