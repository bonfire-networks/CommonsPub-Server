# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Actors.Actor do

  use MoodleNet.Common.Schema
  import MoodleNet.Common.Changeset, only: [meta_pointer_constraint: 1]
  alias Ecto.Changeset
  alias MoodleNet.Actors.{Actor, ActorRevision}
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Peers.Peer

  meta_schema "mn_actor" do
    belongs_to :peer, Peer
    belongs_to :alias, Pointer
    has_many :actor_revisions, ActorRevision
    field :preferred_username, :string
    field :signing_key, :string
    field :published_at, :utc_datetime
    field :deleted_at, :utc_datetime
    timestamps()
  end

  @create_cast ~w(preferred_username peer_id signing_key)a
  @create_required ~w(preferred_username)a

  def create_changeset(pointer_id, attrs) do
    %Actor{id: pointer_id}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> Changeset.unique_constraint(:preferred_username, name: :mn_actor_preferred_username_instance_key)
    |> validate_username()
    |> meta_pointer_constraint()
  end

  @update_cast ~w(preferred_username peer_id signing_key)a
  @update_required ~w(preferred_username)a

  def update_changeset(%Actor{} = actor, attrs) do
    actor
    |> Changeset.cast(attrs, @update_cast)
    |> Changeset.validate_required(@update_required)
    |> Changeset.foreign_key_constraint(:id)
    |> Changeset.unique_constraint(:preferred_username, name: :mn_actor_preferred_username_instance_key)
    |> validate_username()
  end

  defp validate_username(changeset) do
    # TODO
    case Changeset.fetch_change(changeset, :preferred_username) do
      :error -> changeset
      {:ok, name} -> Changeset.put_change(changeset, :preferred_username, name)
    end
  end
end
