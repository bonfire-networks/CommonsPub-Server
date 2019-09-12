defmodule MoodleNet.Peers do
  alias MoodleNet.Repo
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Peers
  alias MoodleNet.Peers.Peer

  @peer_table "mn_peer"
  
  def create(%Pointer{}=pointer, attrs),
    do: Repo.insert(Peer.create_changeset(pointer, attrs))

  def create!(pointer \\ Meta.point!(@peer_table), attrs)
  def create!(%Pointer{}=pointer, attrs),
    do: Repo.insert!(Peer.create_changeset(pointer, attrs))

  def get(id), do: Repo.get(Peer, id)
  
end
