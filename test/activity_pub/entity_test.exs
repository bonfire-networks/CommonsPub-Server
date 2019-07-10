# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.EntityTest do
  use ExUnit.Case, async: true

  alias ActivityPub.{Builder, Entity}
  alias MoodleNet.Factory

  setup do
    {:ok, entity} = Builder.new(Factory.attributes(:user))
    {:ok, entity: entity}
  end

  test "aspects", %{entity: entity} do
    assert [ActivityPub.ObjectAspect] = Entity.aspects(entity)
  end

  test "fields_for", %{entity: entity} do
    assert [ActivityPub.ObjectAspect = aspect | _] = Entity.aspects(entity)
    fields = Entity.fields_for(entity, aspect)
    assert MapSet.subset?(MapSet.new(fields), MapSet.new(entity))
  end

  test "fields", %{entity: entity} do
    expected_fields = entity
    |> Entity.aspects()
    |> Enum.flat_map(&Entity.fields_for(entity, &1))
    assert expected_fields == Entity.fields(entity)
  end

  test "assocs_for", %{entity: entity} do
    assert [ActivityPub.ObjectAspect = aspect | _] = Entity.aspects(entity)
    assocs = Entity.assocs_for(entity, aspect)
    refute Enum.empty?(assocs.icon)
    refute Enum.empty?(assocs.location)
  end

  test "assocs", %{entity: entity} do
    expected_assocs = entity
    |> Entity.aspects()
    |> Enum.flat_map(&Entity.assocs_for(entity, &1))
    |> Enum.into(%{})
    assert expected_assocs == Entity.assocs(entity)
  end

  test "extension_fields", %{entity: entity} do
    assert %{} = Entity.extension_fields(entity)

    extension_entity = Map.put(entity, "extension", true)
    assert %{"extension" => true} = Entity.extension_fields(extension_entity)
  end

  # TODO: setup non local
  test "local?", %{entity: entity} do
    assert Entity.local?(entity)
  end

  test "status", %{entity: entity} do
    assert Entity.status(entity) == :new
  end

  test "local_id", %{entity: entity} do
    assert Entity.local_id(entity) == nil
  end
end
