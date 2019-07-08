# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule AcivityPub.IRITest do
  use ExUnit.Case, async: true

  alias ActivityPub.IRI

  @rfc_examples %{
    "http://www.example.org/D%C3%BCrst" => "http://www.example.org/D%FCrst",
    "http://www.example.org/D<c3><bc>rst" => "http://www.example.org/D<fc>rst",
    "http://www.example.org/D&#xFC;rst" => "http://www.example.org/D%FCrst"
  }

  describe "parse" do
    test "accepts URL's" do
      url = Faker.Internet.url()
      assert {:ok, ^url} = IRI.parse(%{url: url}, :url)
    end

    @tag :skip
    test "accepts examples from spec" do
      for {example, expected} <- @rfc_examples do
        assert {:ok, ^expected} = IRI.parse(%{url: example}, :url)
      end
    end

    test "fails for relative references" do
      assert {:error, error} = IRI.parse(%{url: "/api/oauth"}, :url)
      assert %ActivityPub.BuildError{
        message: "invalid_scheme",
        path: [:url],
        value: "/api/oauth"
      }
    end
  end

  describe "validate" do
    test "accepts URL's" do
      assert :ok = IRI.validate(Faker.Internet.url())
    end

    test "accepts examples from spec" do
      for {example, _} <- @rfc_examples do
        assert :ok = IRI.validate(example)
      end
    end

    test "fails for relative references" do
      assert {:error, :invalid_scheme} = IRI.validate("/api/oauth")
    end

    test "fails for invalid IRI's" do
      assert {:error, :invalid_scheme} = IRI.validate("social.example")
      assert {:error, :invalid_host} = IRI.validate("https://")
    end
  end
end
