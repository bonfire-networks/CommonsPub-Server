# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.MediaProxy.URLBuilderTest do
  use ExUnit.Case, async: true

  alias MoodleNet.MediaProxy.URLBuilder

  @base_url MoodleNetWeb.base_url()

  describe "encode/1" do
    test "preserves filename" do
      assert URLBuilder.encode("pictures/image.png") =~ ~r/\/image\.png$/
      assert URLBuilder.encode("http://example.com/image.png") =~ ~r/\/image\.png$/
    end

    test "doesn't proxy local url" do
      local_url = @base_url
      |> URI.merge("/images/logo.png")
      |> URI.to_string()
      assert URLBuilder.encode(local_url) == local_url
    end

    test "absolute url" do
      url = URLBuilder.encode("http://example.com/important.pdf")
      refute url =~ "http://example.com"
      assert url =~ @base_url
    end

    test "relative url" do
      url = URLBuilder.encode("docs/important.pdf")
      refute url =~ "docs"
      assert url =~ @base_url
    end
  end

  describe "decode/1" do
    test "round trip" do
      url = "http://example.com/docs/important.pdf?legacy=true"
      assert {:ok, ^url} = url |> URLBuilder.encode() |> URLBuilder.decode()
    end

    test "fails with invalid signature" do
      url = "#{@base_url}/media/INVALID_SIG/INVALID_URL/image.png"
      assert {:error, :invalid_signature} = URLBuilder.decode(url)
    end

    test "fails with invalid URL" do
      assert {:error, :missing_path} = URLBuilder.decode("http://test.net")
      assert {:error, :missing_signature} = URLBuilder.decode(
        "#{@base_url}/media/file.exe"
      )
    end
  end
end
