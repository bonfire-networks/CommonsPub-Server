# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Peers.Peer do
  use Ecto.Schema
  alias Ecto.Changeset
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Peers.Peer
  
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "mn_peer" do
    field :ap_url_base, :string
    field :deleted_at, :utc_datetime_usec
    timestamps()
  end

  @create_cast ~w(ap_url_base)a
  @create_required @create_cast
  def create_changeset(%Pointer{id: id}=pointer, fields) do
    %Peer{}
    |> Changeset.change(id: id)
    |> Changeset.cast(fields, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> Changeset.foreign_key_constraint(:id)
    # |> validate_http_url(:ap_url_base)
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
