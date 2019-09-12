defmodule MoodleNet.PeersTest do
  use MoodleNet.DataCase
  alias MoodleNet.Peers
  import MoodleNet.Test.Faking
  alias MoodleNet.Test.Fake
  
  describe "CRUD" do
    test "insertion and retrieval" do
      Repo.transaction fn ->
	attrs = Fake.peer()
	assert peer = Peers.create!(attrs)
	peer2 = Peers.get(peer.id)
	assert peer == peer2
      end
    end
  end
end
