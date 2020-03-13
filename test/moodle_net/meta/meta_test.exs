defmodule MoodleNet.MetaTest do
  use ExUnit.Case, async: true

  import ExUnit.Assertions
  import MoodleNet.Meta.Introspection, only: [ecto_schema_table: 1]
  import MoodleNet.Test.Faking
  alias MoodleNet.{Access, Repo}

  alias MoodleNet.Meta.{
    Pointer,
    Pointers,
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
  alias MoodleNet.Common.NotInTransactionError
  alias MoodleNet.Feeds.Feed
  alias MoodleNet.Peers.Peer
  alias MoodleNet.Users.User
  alias MoodleNet.Localisation.{Country, Language}

  @known_schemas [
    Table, Feature, Feed, Peer, User, Community, Collection, Resource, Comment,
    Thread, Flag, Follow, Like, Country, Language, RegisterEmailAccess,
    RegisterEmailDomainAccess, Block, Activity,
  ]
  @known_tables Enum.map(@known_schemas, &ecto_schema_table/1)
  @table_schemas Map.new(Enum.zip(@known_tables, @known_schemas))
  @expected_table_names Enum.sort(@known_tables)

  describe "MoodleNet.Meta.Pointers.TableService" do
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

  describe "MoodleNet.Pointers.forge!" do
    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(MoodleNet.Repo)
      {:ok, %{}}
    end

    test "forges a pointer for a peer" do
      peer = fake_peer!()
      pointer = Pointers.forge!(peer)
      assert pointer.id == peer.id
      assert pointer.pointed == peer
      assert pointer.table_id == pointer.table.id
      assert pointer.table.table == "mn_peer"
    end

    test "forges a pointer for a user" do
      user = fake_user!()
      pointer = Pointers.forge!(user)
      assert pointer.id == user.id
      assert pointer.pointed == user
      assert pointer.table_id == pointer.table.id
      assert pointer.table.table == "mn_user"
    end

    # TODO: others
    # @tag :skip
    # test "forges a pointer for a " do
    # end

    test "throws TableNotFoundError when given a non-meta table" do
      table = %Access.Token{}

      assert %TableNotFoundError{table: Access.Token} ==
               catch_throw(Pointers.forge!(table))
    end
  end

  describe "MoodleNet.Meta.Pointers.follow" do
    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(MoodleNet.Repo)
      {:ok, %{}}
    end

    test "follows pointers" do
      Repo.transaction(fn ->
        assert peer = fake_peer!()
        assert pointer = Pointers.one!(id: peer.id)
        assert table = Pointers.table!(pointer)
        assert table.table == "mn_peer"
        assert table.schema == Peer
        assert table.id == pointer.table_id
        peer = Map.drop(peer, [:is_disabled])
        assert peer2 = Pointers.follow!(pointer)
        assert Map.drop(peer2, [:is_disabled]) == peer
      end)
    end

    test "preload! can load one pointer" do
      Repo.transaction(fn ->
        assert peer = fake_peer!() |> Map.drop([:is_disabled])
        assert pointer = Pointers.one!(id: peer.id)
        assert table = Pointers.table!(pointer)
        assert table.table == "mn_peer"
        assert table.schema == Peer
        assert table.id == pointer.table_id
        assert pointer2 = Pointers.preload!(pointer)
        assert Map.drop(pointer2.pointed, [:is_disabled]) == peer
        assert pointer2.id == pointer.id
        assert pointer2.table_id == pointer.table_id
        assert [pointer3] = Pointers.preload!([pointer])
        assert pointer2 == pointer3
      end)
    end

    test "preload! can load many pointers" do
      Repo.transaction(fn ->
        assert peer = fake_peer!()
        assert peer2 = fake_peer!()
        assert pointer = Pointers.one!(id: peer.id)
        assert pointer2 = Pointers.one!(id: peer2.id)
        assert [pointer3, pointer4] = Pointers.preload!([pointer, pointer2])
        assert pointer3.id == pointer.id
        assert pointer4.id == pointer2.id
        assert pointer3.table_id == pointer.table_id
        assert pointer4.table_id == pointer2.table_id
        assert Map.drop(pointer3.pointed, [:is_disabled]) == Map.drop(peer, [:is_disabled])
        assert Map.drop(pointer4.pointed, [:is_disabled]) == Map.drop(peer2, [:is_disabled])
      end)
    end

    # TODO: merge antonis' work and figure out preloads
    test "preload! can load many pointers of many types" do
      Repo.transaction(fn ->
        assert peer = fake_peer!()
        assert peer2 = fake_peer!()
        assert user = fake_user!()
        assert user2 = fake_user!()
        assert actor = fake_actor!()
        assert pointer = Pointers.one!(id: peer.id)
        assert pointer2 = Pointers.one!(id: peer2.id)
        assert pointer3 = Pointers.one!(id: user.id)
        assert pointer4 = Pointers.one!(id: user2.id)

        assert [pointer5, pointer6, pointer7, pointer8] =
                 Pointers.preload!([pointer, pointer2, pointer3, pointer4])

        assert pointer5.id == pointer.id
        assert pointer6.id == pointer2.id
        assert pointer7.id == pointer3.id
        assert pointer8.id == pointer4.id
        assert Map.drop(pointer5.pointed, [:is_disabled]) == Map.drop(peer, [:is_disabled])
        assert Map.drop(pointer6.pointed, [:is_disabled]) == Map.drop(peer2, [:is_disabled])
        pointed7 = Map.drop(pointer7.pointed, [:actor, :local_user, :email_confirm_tokens, :is_disabled, :is_public, :is_deleted, :canonical_url, :is_local, :preferred_username])
        user3 = Map.drop(user, [:actor, :local_user, :email_confirm_tokens, :is_disabled, :is_public, :is_deleted, :canonical_url, :is_local, :preferred_username])
        assert pointed7 == user3
        pointed8 = Map.drop(pointer8.pointed, [:actor, :local_user, :email_confirm_tokens, :is_disabled, :is_public, :is_deleted, :canonical_url, :is_local, :preferred_username])
        user4 = Map.drop(user2, [:actor, :local_user, :email_confirm_tokens, :is_disabled, :is_public, :is_deleted, :canonical_url, :is_local, :preferred_username])
        assert pointed8 == user4
      end)
    end

    test "key error does not occur for missing ID's" do
      
    end
  end
end
