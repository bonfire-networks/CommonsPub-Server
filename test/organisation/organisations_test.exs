# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Organisation.OrganisationsTest do
  use MoodleNetWeb.ConnCase, async: true
  import MoodleNet.Test.Faking

  import Organisation.Test.Faking
  alias Organisation.Organisations

  describe "one" do
    test "fetches an existing organisation" do
      user = fake_user!()
      org = fake_organisation!(user)

      assert {:ok, fetched} = Organisations.one(id: org.id)
    end
  end

  describe "create" do
    test "a user can create an org" do
      user = fake_user!()
      assert {:ok, org} = Organisations.create(user, organisation())
      assert_organisation(org)
    end
  end

  describe "update" do
    
  end

  describe "soft_delete" do
    
  end
end
