# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.SQL.PaginateTest do
  use MoodleNet.DataCase, async: true

  alias MoodleNet.Factory
  alias ActivityPub.SQL.{Paginate, Query}

  def insert(map) do
    {:ok, e} = ActivityPub.new(map)
    {:ok, e} = ActivityPub.SQLEntity.insert(e)
    e
  end

  def entity_local_id(%{id: url_id}) do
    {:ok, id} = ActivityPub.UrlBuilder.get_local_id(url_id)
    id
  end

  describe "by_local_id/2" do
    test "limits" do
      for _ <- 0..10, do: insert(%{})
      assert 2 = Query.new()
      |> Paginate.by_local_id(%{limit: 2})
      |> Query.count()
    end

    # FIXME: ID's aren't always linear, hard to test
    @tag :skip
    test "before and after" do
      entities = for _ <- 0..10, do: insert(%{})
      params = %{
        before: entity_local_id(List.first(entities)) + 2,
        after: entity_local_id(List.last(entities)) - 2
      }
      assert 5 = Query.new()
      |> Paginate.by_local_id(params)
      |> Query.count()
    end
  end
end
