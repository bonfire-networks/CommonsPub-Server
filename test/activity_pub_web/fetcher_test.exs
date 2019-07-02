# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.FetcherTest do
  use MoodleNet.DataCase
  import Tesla.Mock

  alias ActivityPubWeb.Fetcher

  setup do
    mock(fn
      %{method: :get, url: "https://pleroma.example/userisgone404"} ->
        %Tesla.Env{status: 404}

      %{method: :get, url: "https://pleroma.example/userisgone410"} ->
        %Tesla.Env{status: 410}

      env ->
        apply(HttpRequestMock, :request, [env])
    end)

    :ok
  end

  describe "fetching objects" do
    test "fetches a pleroma note" do
      {:ok, entity} =
        Fetcher.fetch_object_from_id(
          "https://kawen.space/objects/eb3b1181-38cc-4eaf-ba1b-3f5431fa9779"
        )

      assert entity
    end
  end

  describe "handles errors" do
    test "handle HTTP 410 Gone response" do
      assert {:error, "Object has been deleted"} ==
               Fetcher.fetch_remote_object_from_id("https://pleroma.example/userisgone410")
    end

    test "handle HTTP 404 response" do
      assert {:error, "Object has been deleted"} ==
               Fetcher.fetch_remote_object_from_id("https://pleroma.example/userisgone404")
    end
  end
end
