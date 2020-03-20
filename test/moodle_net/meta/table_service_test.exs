# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Meta.TableServiceTest do
  use ExUnit.Case, async: true

  import ExUnit.Assertions
  import MoodleNet.Meta.Introspection, only: [ecto_schema_table: 1]
  alias MoodleNet.Repo

  alias MoodleNet.Meta.{
    Table,
    TableService,
    TableNotFoundError
  }

  alias MoodleNet.Access.{RegisterEmailAccess, RegisterEmailDomainAccess}
  alias MoodleNet.Activities.Activity
  alias MoodleNet.Communities.Community
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Threads.{Comment, Thread}

  alias MoodleNet.Blocks.Block
  alias MoodleNet.Flags.Flag
  alias MoodleNet.Follows.Follow
  alias MoodleNet.Features.Feature
  alias MoodleNet.Likes.Like
  alias MoodleNet.Feeds.Feed
  alias MoodleNet.Peers.Peer
  alias MoodleNet.Users.User
  alias MoodleNet.Localisation.{Country, Language}

  @known_schemas [
    Table,
    Feature,
    Feed,
    Peer,
    User,
    Community,
    Collection,
    Resource,
    Comment,
    Thread,
    Flag,
    Follow,
    Like,
    Country,
    Language,
    RegisterEmailAccess,
    RegisterEmailDomainAccess,
    Block,
    Activity
  ]
  @known_tables Enum.map(@known_schemas, &ecto_schema_table/1)
  @table_schemas Map.new(Enum.zip(@known_tables, @known_schemas))
  @expected_table_names Enum.sort(@known_tables)

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MoodleNet.Repo)
    {:ok, %{}}
  end

  test "is fetching from good source data" do
    in_db =
      Repo.all(Table)
      |> Enum.map(& &1.table)
      |> Enum.sort()

    assert @expected_table_names == in_db
  end

  @bad_table_names ["fizz", "buzz bazz"]

  test "returns results consistent with the source data" do
    # the database will be our source of truth
    tables = Repo.all(Table)
    assert Enum.count(tables) == Enum.count(@expected_table_names)
    # Every db entry must match up to our module metadata
    for t <- tables do
      assert %{id: id, table: table} = t
      # we must know about this schema to pair it up
      assert schema = Map.fetch!(@table_schemas, table)
      assert schema in @known_schemas
      t2 = %{t | schema: schema}
      # There are 3 valid keys, 3 pairs of functions to check
      for key <- [schema, table, id] do
        assert {:ok, t2} == TableService.lookup(key)
        assert {:ok, id} == TableService.lookup_id(key)
        assert {:ok, schema} == TableService.lookup_schema(key)
        assert t2 == TableService.lookup!(key)
        assert id == TableService.lookup_id!(key)
        assert schema == TableService.lookup_schema!(key)
      end
    end

    for t <- @bad_table_names do
      assert {:error, %TableNotFoundError{table: t}} == TableService.lookup(t)
      assert %TableNotFoundError{table: t} == catch_throw(TableService.lookup!(t))
    end
  end
end
