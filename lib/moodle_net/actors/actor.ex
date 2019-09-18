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

  # TODO: match the agreed rules
  @username_regex ~r([a-zA-Z0-9]+)

  meta_schema "mn_actor" do
    belongs_to :instance, Instance
    belongs_to :peer, MoodleNet.Peers.Peer
    belongs_to :alias, MoodleNet.Meta.Pointer
    has_many :actor_revisions, ActorRevision
    field :preferred_username, :string
    field :signing_key, :string
    field :published_at, :utc_datetime_usec
    field :deleted_at, :utc_datetime_usec
    timestamps()
  end

  @create_cast ~w(preferred_username peer_id signing_key icon image)a
  @create_required ~w(preferred_username)a

  def create_changeset(%Pointer{id: id}, attrs) do
    %Actor{id: id}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> Changeset.validate_format(:preferred_username, @username_regex)
    |> Changeset.unique_constraint(:alias_id)
    |> Changeset.unique_constraint(:preferred_username, name: :mn_actor_preferred_username_instance_key)
    |> meta_pointer_constraint()
  end

  @update_cast ~w(preferred_username peer_id signing_key icon image)a
  @update_required ~w(preferred_username)a

  def update_changeset(%Actor{} = actor, attrs) do
    actor
    |> Changeset.cast(attrs, @update_cast)
    |> Changeset.validate_required(@update_required)
    |> Changeset.validate_format(:preferred_username, @username_regex)
    |> Changeset.unique_constraint(:alias_id)
    |> Changeset.unique_constraint([:preferred_username, :peer_id])
    |> meta_pointer_constraint()
  end

end
