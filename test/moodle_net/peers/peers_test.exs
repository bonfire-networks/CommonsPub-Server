defmodule MoodleNet.PeersTest do
  use MoodleNet.DataCase
  alias MoodleNet.Peers
  # alias MoodleNet.Peers.Peer
  import MoodleNet.Test.Faking
  alias MoodleNet.Test.Fake

  describe "CRUD" do
    test "insertion and retrieval" do
      Repo.transaction(fn ->
        attrs = Fake.peer()
        assert {:ok, peer} = Peers.create(attrs)
        assert {:ok, peer2} = Peers.fetch(peer.id)
        assert peer == peer2
      end)
    end

    test "updates" do
      Repo.transaction(fn ->
        peer = fake_peer!()

        attrs =
          peer
          |> Map.from_struct()
          |> Map.delete(:ap_url_base)
          |> Fake.peer()

        assert {:ok, peer2} = Peers.update(peer, attrs)
        assert peer2.id == peer.id
        assert peer2.ap_url_base == attrs[:ap_url_base]
      end)
    end

    # TODO: chasing? discuss.
    test "soft deletion" do
      Repo.transaction(fn ->
        :ok
        peer = fake_peer!()
        assert {:ok, peer2} = Peers.soft_delete(peer)
        assert was_updated_since?(peer2, peer)
        # no deleted() ? not actually deleted, is it? -- jjl
        assert timeless(peer2) == timeless(peer)
      end)
    end

    # TODO: chasing
    @tag :skip
    test "hard deletion" do
      Repo.transaction(fn -> :ok end)
    end
  end
end
