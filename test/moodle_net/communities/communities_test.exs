# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.CommunitiesTest do
  use MoodleNet.DataCase, async: true

  import MoodleNet.Test.Faking
  alias MoodleNet.{Actors, Communities, Localisation}
  alias MoodleNet.Test.Fake

  defp english(), do: Localisation.language!("en")

  describe "create" do
    test "creates a community given valid attributes" do
      assert actor = fake_actor!()
      assert language = english()
      attrs =
	%{creator_id: actor.id, primary_language_id: language.id}
        |> Fake.community()
      assert {:ok, community} = Communities.create(attrs)
      assert community.creator_id == actor.id
      assert community.primary_language_id == language.id
    end

    test "fails if given invalid attributes" do
      assert {:error, changeset} = Communities.create(%{})
      assert Keyword.get(changeset.errors, :creator_id)
      assert Keyword.get(changeset.errors, :primary_language_id)
      assert Keyword.get(changeset.errors, :is_public)
    end
  end

  describe "update" do

    test "updates a community with the given attributes" do
      actor = fake_actor!()
      language = english()
      community = fake_community!(actor, language, %{is_public: true})
      assert {:ok, updated_community} = Communities.update(community, %{is_public: false})
      assert updated_community.id == community.id
      refute updated_community.is_public
    end

  end

  describe "membership" do

    test "joining" do
      # Communities.join()
    end

    test "leaving" do
    end

    test "listing" do
    end

    test "listing as admin" do
    end
  end

  # describe "community flags" do
  #   test "works" do
  #     actor = Factory.actor()
  #     actor_id = local_id(actor)
  #     comm = Factory.community(actor)
  #     comm_id = local_id(comm)

  #     assert [] = Communities.all_flags(actor)

  #     {:ok, _activity} = Communities.flag(actor, comm, %{reason: "Terrible joke"})

  #     assert [flag] = Communities.all_flags(actor)
  #     assert flag.flagged_object_id == comm_id
  #     assert flag.flagging_object_id == actor_id
  #     assert flag.reason == "Terrible joke"
  #     assert flag.open == true
  #   end
  # end

end
