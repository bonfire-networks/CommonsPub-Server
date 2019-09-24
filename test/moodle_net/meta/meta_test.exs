defmodule MoodleNet.MetaTest do
  use ExUnit.Case, async: true

  import ExUnit.Assertions
  import MoodleNet.Meta.Introspection, only: [ecto_schema_table: 1]
  import MoodleNet.Test.Faking
  alias MoodleNet.{Meta, Repo}
  alias MoodleNet.Meta.{
    Pointer,
    Table,
    TableService,
    TableNotFoundError,
  }
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Communities.Community
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Comments.Comment
  alias MoodleNet.Common.{
    Flag,
    Like,
    NotInTransactionError,
  }    
  alias MoodleNet.Peers.Peer
  alias MoodleNet.Users.User

  @known_schemas [Peer, Actor, User, Community, Collection, Resource, Comment, Flag, Like]
  @known_tables Enum.map(@known_schemas, &ecto_schema_table/1)
  @table_schemas Map.new(Enum.zip(@known_tables, @known_schemas))
  @expected_table_names Enum.sort(@known_tables)

  describe "MoodleNet.Meta.TableService" do
    
    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(MoodleNet.Repo)
      {:ok, %{}}
    end
    
    test "is fetching from good source data" do
      in_db = Repo.all(Table)
      |> Enum.map(&(&1.table))
      |> Enum.sort()
      assert @expected_table_names == in_db
    end

    @bad_table_names ["fizz", "buzz bazz"]

    test "returns results consistent with the source data" do
      # the database will be our source of truth
      tables = Repo.all(Table)
      assert Enum.count(tables) == Enum.count(@expected_table_names)
      # Every db entry must match up to our module metadata
      for t <- Repo.all(Table) do
	assert %{id: id, table: table} = t
	# we must know about this schema to pair it up
	assert schema = Map.fetch!(@table_schemas, table)
	assert schema in @known_schemas
	t2 = %{ t | schema: schema }
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

  describe "MoodleNet.Meta.point_to!" do
    test "throws when not in a transaction" do
      expected_error = %NotInTransactionError{cause: "mn_peer"} 
      assert catch_throw(Meta.point_to!("mn_peer")) == expected_error
    end

    test "inserts a pointer when in a transaction" do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(MoodleNet.Repo)
      Repo.transaction fn ->
	%Pointer{} = ptr = Meta.point_to!("mn_peer")
	assert ptr.table_id == TableService.lookup_id!("mn_peer")
	assert ptr.__meta__.state == :loaded
	assert ptr2 = Meta.find!(ptr.id)
	assert ptr2 == ptr
      end
    end
  end

  describe "MoodleNet.Meta." do

    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(MoodleNet.Repo)
      {:ok, %{}}
    end

    test "follow follows pointers" do
      Repo.transaction fn ->
	assert peer = fake_peer!()
	assert pointer = Meta.find!(peer.id)
	assert table = Meta.points_to!(pointer)
	assert table.table == "mn_peer"
	assert table.schema == Peer
	assert table.id == pointer.table_id
	assert {:ok, peer2} = Meta.follow(pointer)
	assert peer3 = Meta.follow!(pointer)
	assert peer2 == peer
	assert peer3 == peer
      end
    end

    test "preload! can load one pointer" do
      Repo.transaction fn ->
	assert peer = fake_peer!()
	assert pointer = Meta.find!(peer.id)
	assert table = Meta.points_to!(pointer)
	assert table.table == "mn_peer"
	assert table.schema == Peer
	assert table.id == pointer.table_id
	assert pointer2 = Meta.preload!(pointer)
	assert pointer2.pointed == peer
	assert pointer2.id == pointer.id
	assert pointer2.table_id == pointer.table_id
	assert [pointer3] = Meta.preload!([pointer])
	assert pointer2 == pointer3
      end
    end

    test "preload! can load many pointers" do
      Repo.transaction fn ->
	assert peer = fake_peer!()
	assert peer2 = fake_peer!()
	assert pointer = Meta.find!(peer.id)
	assert pointer2 = Meta.find!(peer2.id)

	assert [pointer3, pointer4] = Meta.preload!([pointer, pointer2])
	assert pointer3.id == pointer.id
	assert pointer4.id == pointer2.id
	assert pointer3.table_id == pointer.table_id
	assert pointer4.table_id == pointer2.table_id
	assert pointer3.pointed == peer
	assert pointer4.pointed == peer2
      end
    end
  end

end
