# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.WebFingerTest do
  use CommonsPub.DataCase

  alias ActivityPub.WebFinger
  alias ActivityPub.Actor
  alias CommonsPub.Test.Faking

  import Tesla.Mock

  setup do
    mock(fn env -> apply(HttpRequestMock, :request, [env]) end)
    :ok
  end

  describe "incoming webfinger request" do
    test "works for fqns" do
      actor = Faking.fake_user!()

      {:ok, result} =
        WebFinger.webfinger(
          "#{actor.character.preferred_username}@#{CommonsPub.Web.Endpoint.host()}"
        )

      assert is_map(result)
    end

    test "works for ap_ids" do
      actor = Faking.fake_user!()
      {:ok, ap_actor} = Actor.get_by_username(actor.character.preferred_username)

      {:ok, result} = WebFinger.webfinger(ap_actor.data["id"])
      assert is_map(result)
    end
  end

  describe "fingering" do
    test "works with pleroma" do
      user = "karen@kawen.space"

      {:ok, data} = WebFinger.finger(user)

      assert data["id"] == "https://kawen.space/users/karen"
    end

    test "works with mastodon" do
      user = "karen@niu.moe"

      {:ok, data} = WebFinger.finger(user)

      assert data["id"] == "https://niu.moe/users/karen"
    end
  end
end
