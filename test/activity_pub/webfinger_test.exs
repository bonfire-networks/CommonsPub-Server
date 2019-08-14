defmodule ActivityPub.WebFingerTest do

  use MoodleNet.DataCase

  alias ActivityPub.WebFinger

 describe "incoming webfinger request" do
    test "works for fqns" do
      actor = Factory.actor()

      {:ok, result} =
        WebFinger.webfinger("#{actor.preferred_username}@#{MoodleNetWeb.base_url()}")

      assert is_map(result)
    end

    test "works for ap_ids" do
      actor = Factory.actor()

      {:ok, result} = WebFinger.webfinger(actor.id)
      assert is_map(result)
    end
  end
end
