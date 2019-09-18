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
    NotInTransactionError,
  }    
  alias MoodleNet.Peers.Peer
  alias MoodleNet.Users.User

  @known_schemas [Peer, Actor, User, Community, Collection, Resource, Comment, Flag]
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

  describe "MoodleNet.Meta." do
    test "point_to! throws when not in a transaction" do
      expected_error = %NotInTransactionError{cause: "mn_peer"} 
      assert catch_throw(Meta.point_to!("mn_peer")) == expected_error
    end

    test "pointer! inserts a pointer when in a transaction" do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(MoodleNet.Repo)
      Repo.transaction fn ->
	%Pointer{} = ptr = Meta.point_to!("mn_peer")
	assert ptr.table_id == TableService.lookup_id!("mn_peer")
	assert ptr.__meta__.state == :loaded
	assert ptr2 = Meta.find!(ptr.id)
	assert ptr2 == ptr
      end
    end

    test "following pointers - peers" do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(MoodleNet.Repo)
      Repo.transaction fn ->
	assert peer = fake_peer!()
	assert pointer = Meta.find!(peer.id)
	assert table = Meta.points_to!(pointer)
	assert table.table == "mn_peer"
	assert table.schema == Peer
	assert table.id == pointer.table_id
	assert peer2 = Meta.follow!(pointer)
	assert peer2 == peer
      end
    end

    @tag :skip
    test "following many pointers" do
    end
  end

end
