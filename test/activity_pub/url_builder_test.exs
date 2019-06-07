# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.UrlBuilderTest do
  use MoodleNet.DataCase

  alias ActivityPub.UrlBuilder

  @base_url Application.get_env(:moodle_net, :ap_base_url)

  describe "get_local_id" do
    test "works with regular entities" do
      assert {:ok, 1} = UrlBuilder.get_local_id("#{@base_url}/1")
    end

    test "works with pages" do
      assert {:ok, {:page, 1, %{}}} = UrlBuilder.get_local_id("#{@base_url}/1/page")

      assert {:ok, {:page, 1, %{"after" => "1", "limit" => "1"}}} =
               UrlBuilder.get_local_id("#{@base_url}/1/page?after=1&limit=1")
    end

    test "returns errors" do
      assert :error = UrlBuilder.get_local_id("http://test.localhost:4001/activity_pub")
      assert :error = UrlBuilder.get_local_id("http://test.localhost:4001/activity_pubs/1")
      assert :error = UrlBuilder.get_local_id("https://test.localhost:4001/activity_pub/1")
      assert :error = UrlBuilder.get_local_id("http://test.localhost:4001/activity_pub/1/leave")
      assert :error = UrlBuilder.get_local_id("http://localhost:4001/activity_pub/1")
      assert :error = UrlBuilder.get_local_id("http://test.localhost:4000/activity_pub/1")
      assert :error = UrlBuilder.get_local_id("http://test.localhost:4001/activity_pub/uno")
      assert :error = UrlBuilder.get_local_id("https://google.com/1")
    end
  end
end
