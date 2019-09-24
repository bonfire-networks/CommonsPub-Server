defmodule MoodleNet.PeersTest do
  use MoodleNet.DataCase
  alias MoodleNet.{Meta, Peers}
  alias MoodleNet.Peers.Peer
  import MoodleNet.Test.Faking
  alias MoodleNet.Test.Fake

  describe "CRUD" do

    test "insertion and retrieval" do
      Repo.transaction fn ->
	attrs = Fake.peer()
	assert {:ok, peer} = Peers.create(attrs)
	assert {:ok, peer2} = Peers.fetch(peer.id)
	assert peer == peer2
      end
    end

    test "updates" do
      Repo.transaction fn ->
        peer = fake_peer!()
        attrs =
          peer
          |> Map.from_struct()
          |> Map.delete(:ap_url_base)
          |> Fake.peer()
        assert {:ok, peer2} = Peers.update(peer, attrs)
        assert peer2.id == peer.id
        assert peer2.ap_url_base == attrs[:ap_url_base]
      end
    end

    @tag :skip
    test "soft deletion" do
      Repo.transaction fn -> :ok
        peer = fake_peer!()
      end
    end

    @tag :skip
    test "hard deletion" do
      Repo.transaction fn -> :ok
      end
    end
  end
end
