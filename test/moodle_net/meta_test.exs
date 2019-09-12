defmodule MoodleNet.MetaTest do
  use ExUnit.Case, async: true

  import ExUnit.Assertions
  alias MoodleNet.Repo
  alias MoodleNet.Meta
  alias MoodleNet.Meta.{Pointer, Table, TableService, TableNotFoundError, NotInTransactionError}

  @expected_tables Enum.sort(~w(mn_peer mn_actor mn_user mn_community mn_collection mn_resource mn_comment mn_flag))

  describe "MoodleNet.Meta.TableService" do
    
    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(MoodleNet.Repo)
      {:ok, %{}}
    end
    
    test "is fetching from good source data" do
      in_db = Repo.all(Table)
      |> Enum.map(&(&1.table))
      |> Enum.sort()
      assert @expected_tables == in_db
    end

    @bad_table_names ["fizz", "buzz bazz"]

    test "returns results consistent with the source data" do
      tables = Repo.all(Table)
      assert Enum.count(tables) == Enum.count(@expected_tables)
      for t <- Repo.all(Table) do
	assert %{id: id, table: table} = t
	assert {:ok, t} == TableService.lookup(table)
	assert {:ok, t} == TableService.lookup(id)
	assert t == TableService.lookup!(table)
	assert t == TableService.lookup!(id)
	assert id == TableService.lookup_id!(table)
	assert id == TableService.lookup_id!(id)
      end
      for t <- @bad_table_names do
	assert {:error, %TableNotFoundError{table: t}} == TableService.lookup(t)
      end
    end
  end

  describe "MoodleNet.Meta." do
    test "pointer! throws when not in a transaction" do
      expected_error = %NotInTransactionError{cause: {Meta, :pointer!, ["mn_peer"]}} 
      assert catch_throw(Meta.point!("mn_peer")) == expected_error
    end

    test "pointer! inserts a pointer when in a transaction" do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(MoodleNet.Repo)
      Repo.transaction(fn ->
	%Pointer{} = ptr = Meta.point!("mn_peer")
	assert ptr.table_id == TableService.lookup_id!("mn_peer")
	assert ptr.__meta__.state == :loaded
	assert ptr2 = Meta.find(ptr.id)
	assert ptr2 == ptr
      end)
    end

    test "following pointers" do
    end
  end

end
