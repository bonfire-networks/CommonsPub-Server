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
  import MoodleNet.Common.Changeset, only: [meta_pointer_constraint: 1]
  alias Ecto.Changeset
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Peers.Peer
  
  meta_schema "mn_peer" do
    field :ap_url_base, :string
    field :deleted_at, :utc_datetime_usec
    timestamps()
  end

  @create_cast ~w(ap_url_base)a
  @create_required @create_cast

  @update_cast ~w(ap_url_base)a
  @update_required @update_cast

  def create_changeset(%Pointer{id: id}=pointer, fields) do
    Meta.assert_points_to!(pointer, __MODULE__)
    %Peer{id: id}
    |> Changeset.cast(fields, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> meta_pointer_constraint()
    # |> validate_http_url(:ap_url_base)
  end

  def update_changeset(%Peer{}=peer, fields) do
    peer
    |> Changeset.cast(fields, @update_cast)
    |> Changeset.validate_required(@update_required)
    |> meta_pointer_constraint()
  end
  
  # TODO
  def validate_http_url(changeset, _field), do: changeset
    # case Changeset.fetch_change(changeset, field) do
    #   {:ok, change} ->
    # 	case URI.parse
    # end
  # TODO
  # defp parse_http_url(url) when is_binary(url) do
  #   uri = URI.parse(url)
  #   valid = (uri.scheme in ["http", "https"]) && not is_nil(uri.host)
  #   && not is_nil(uri.path)
  # end
end
