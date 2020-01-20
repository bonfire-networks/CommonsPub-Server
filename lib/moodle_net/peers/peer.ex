# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Peers.Peer do
  @moduledoc """
  A Peer is a remote server we interact with via one or more protocols, currently:

  * ActivityPub

  Peers participate in the meta system and must be created from a Pointer
  """
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset,
    only: [validate_http_url: 2, change_synced_timestamp: 3]

  alias Ecto.Changeset
  alias MoodleNet.Peers.Peer

  table_schema "mn_peer" do
    field(:ap_url_base, :string)
    field(:domain, :string)
    field(:deleted_at, :utc_datetime_usec)
    field(:is_disabled, :boolean, virtual: true)
    field(:disabled_at, :utc_datetime_usec)
    timestamps()
  end

  @required ~w(ap_url_base domain)a
  @cast @required ++ ~w(is_disabled)a

  def create_changeset(fields) do
    %Peer{}
    |> Changeset.cast(fields, @cast)
    |> Changeset.validate_required(@required)
    |> change_synced_timestamp(:is_disabled, :disabled_at)
    |> validate_http_url(:ap_url_base)
  end

  def update_changeset(%Peer{} = peer, fields) do
    peer
    |> Changeset.cast(fields, @cast)
    |> change_synced_timestamp(:is_disabled, :disabled_at)
  end
end
