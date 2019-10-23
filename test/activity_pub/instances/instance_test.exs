# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.Instances.InstanceTest do
  alias ActivityPub.Instances.Instance
  alias MoodleNet.Repo
  alias MoodleNet.Test.Faking

  require Ecto.Query

  use MoodleNet.DataCase

  setup_all do
    config_path = [:instance, :federation_reachability_timeout_days]
    initial_setting = MoodleNet.Config.get(config_path)

    MoodleNet.Config.put(config_path, 1)
    on_exit(fn -> MoodleNet.Config.put(config_path, initial_setting) end)

    :ok
  end

  describe "set_reachable/1" do
    test "clears `unreachable_since` of existing matching Instance record having non-nil `unreachable_since`" do
      {:ok, instance} = Faking.fake_instance(NaiveDateTime.utc_now())

      assert {:ok, instance} = Instance.set_reachable(instance.host)
      refute instance.unreachable_since
    end

    test "keeps nil `unreachable_since` of existing matching Instance record having nil `unreachable_since`" do
      {:ok, instance} = Faking.fake_instance

      assert {:ok, instance} = Instance.set_reachable(instance.host)
      refute instance.unreachable_since
    end

    test "does NOT create an Instance record in case of no existing matching record" do
      host = "domain.org"
      assert nil == Instance.set_reachable(host)

      assert [] = Repo.all(Ecto.Query.from(i in Instance))
      assert Instance.reachable?(host)
    end
  end

  describe "set_unreachable/1" do
    test "creates new record having `unreachable_since` to current time if record does not exist" do
      assert {:ok, instance} = Instance.set_unreachable("https://domain.com/path")

      instance = Repo.get(Instance, instance.id)
      assert instance.unreachable_since
      assert "domain.com" == instance.host
    end

    test "does NOT modify `unreachable_since` value of existing record in case it's present" do
      {:ok, instance} = Faking.fake_instance(NaiveDateTime.add(NaiveDateTime.utc_now(), -10))

      assert instance.unreachable_since
      initial_value = instance.unreachable_since

      assert {:ok, _} = Instance.set_unreachable(instance.host)

      instance = Repo.get(Instance, instance.id)
      assert initial_value == instance.unreachable_since
    end
  end

  describe "set_unreachable/2" do
    test "sets `unreachable_since` value of existing record in case it's newer than supplied value" do
      {:ok, instance} = Faking.fake_instance(NaiveDateTime.add(NaiveDateTime.utc_now(), -10))

      assert instance.unreachable_since

      past_value = NaiveDateTime.add(NaiveDateTime.utc_now(), -100)
      assert {:ok, _} = Instance.set_unreachable(instance.host, past_value)

      instance = Repo.get(Instance, instance.id)
      assert past_value == instance.unreachable_since
    end

    test "does NOT modify `unreachable_since` value of existing record in case it's equal to or older than supplied value" do
      {:ok, instance} = Faking.fake_instance(NaiveDateTime.add(NaiveDateTime.utc_now(), -10))

      assert instance.unreachable_since
      initial_value = instance.unreachable_since

      assert {:ok, _} = Instance.set_unreachable(instance.host, NaiveDateTime.utc_now())

      instance = Repo.get(Instance, instance.id)
      assert initial_value == instance.unreachable_since
    end
  end
end
