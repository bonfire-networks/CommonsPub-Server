# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.GuardsTest do
  use MoodleNet.DataCase, async: true

  defmodule Foo do
    import ActivityPub.Guards

    def is_entity?(e) when is_entity(e), do: true
    def is_entity?(_), do: false

    def has_activity_type(e) when has_type(e, "Activity"), do: true
    def has_activity_type(_), do: false

    def has_actor_aspect(e) when has_aspect(e, ActivityPub.ActorAspect), do: true
    def has_actor_aspect(_), do: false

    def has_status_new(e) when has_status(e, :new), do: true
    def has_status_new(_), do: false

    def local_id?(e) when has_local_id(e), do: true
    def local_id?(_), do: false
  end

  test "works" do
    assert {:ok, actor} = ActivityPub.new(%{type: "Person"})
    assert {:ok, activity} = ActivityPub.new(%{type: "Follow"})

    assert Foo.is_entity?(actor)
    refute Foo.is_entity?(%{})

    assert Foo.has_activity_type(activity)
    refute Foo.has_activity_type(actor)

    refute Foo.has_actor_aspect(activity)
    assert Foo.has_actor_aspect(actor)

    assert Foo.has_status_new(actor)
    refute Foo.local_id?(actor)
    assert {:ok, persisted} = ActivityPub.insert(actor)
    refute Foo.has_status_new(persisted)
    assert Foo.local_id?(persisted)
  end
end
