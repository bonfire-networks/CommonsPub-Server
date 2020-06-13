# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Circle.CirclesTest do
  use MoodleNetWeb.ConnCase, async: true
  import MoodleNet.Test.Faking

  import Circle.Test.Faking
  alias Circle.Circles

  describe "one" do
    test "fetches an existing circle" do
      user = fake_user!()
      org = fake_circle!(user)

      assert {:ok, fetched} = Circles.one(id: org.id)
      assert_circle(fetched)
    end
  end

  describe "create" do
    test "a user can create an org" do
      user = fake_user!()
      assert {:ok, org} = Circles.create(user, circle())
      assert_circle(org)
      assert org.character.creator_id == user.id
    end

    test "a user can create an org for a context" do
      user = fake_user!()
      comm = fake_community!(user)
      assert {:ok, org} = Circles.create(user, comm, circle())
      assert_circle(org)
      assert org.character.context_id == comm.id
    end

    test "fails with invalid parameters" do
      user = fake_user!()
      assert {:error, %Ecto.Changeset{}} = Circles.create(user, %{})
    end
  end

  describe "update" do
    test "updates an existing org with new content" do
      user = fake_user!()
      org = fake_circle!(user)
      assert {:ok, updated} = Circles.update(user, org, circle())
      assert_circle(updated)
      assert org != updated
    end
  end

  # describe "soft_delete" do
  #   test "marks an exisitng org as deleted" do
  #     org = fake_user!() |> fake_circle!()
  #     assert {:ok, org} = Circles.soft_delete(org)
  #     assert_circle(org)
  #     assert org.deleted_at
  #   end
  # end
end
