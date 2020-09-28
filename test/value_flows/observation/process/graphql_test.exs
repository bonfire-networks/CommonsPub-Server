defmodule ValueFlows.Observation.Process.GraphQLTest do
  use CommonsPub.Web.ConnCase, async: true

  import CommonsPub.Utils.Trendy, only: [some: 2]
  import CommonsPub.Utils.Simulation
  import CommonsPub.Test.Faking
  alias Grumble.PP

  import ValueFlows.Simulate
  import ValueFlows.Test.Faking

  alias ValueFlows.Observation.Process.Processes

  describe "Process" do
    test "fetches a process by ID" do
      user = fake_user!()
      process = fake_process!(user)
      IO.inspect(process.id)
      q = process_query()
      IO.puts(PP.to_string(q))
      conn = user_conn(user)
      IO.puts(PP.to_string(grumble_post_key(q, conn, :process, %{id: process.id})))

      assert_process(grumble_post_key(q, conn, :process, %{id: process.id}))
    end

    test "fails if has been deleted" do
      user = fake_user!()
      spec = fake_process!(user)

      q = process_query()
      conn = user_conn(user)

      assert {:ok, spec} = Processes.soft_delete(spec)
      assert [%{"code" => "not_found", "path" => ["process"], "status" => 404}] =
              grumble_post_errors(q, conn, %{id: spec.id})
    end
  end

  describe "Processes" do
    test "returns a list of Processes" do
      # users = some_fake_users!(3)
      # # 9
      # process_specs = some_fake_Processes!(3, users)

      # root_page_test(%{
      #   query: Processes_query(),
      #   connection: json_conn(),
      #   return_key: :Processes,
      #   default_limit: 5,
      #   total_count: 9,
      #   data: order_follower_count(Processes),
      #   assert_fn: &assert_collection/2,
      #   cursor_fn: Collections.test_cursor(:followers),
      #   after: :collections_after,
      #   before: :collections_before,
      #   limit: :collections_limit
      # })
    end
  end

  describe "createProcess" do
    test "create a new process" do
      user = fake_user!()
      q = create_process_mutation()
      conn = user_conn(user)
      vars = %{process: process_input()}
      assert spec = grumble_post_key(q, conn, :create_process, vars)["process"]
      assert_process(spec)
    end

    test "create a new process with a scope" do
      user = fake_user!()
      parent = fake_user!()

      q = create_process_mutation()
      conn = user_conn(user)
      vars = %{process: process_input(%{"inScopeOf" => parent.id})}
      assert spec = grumble_post_key(q, conn, :create_process, vars)["process"]
      assert_process(spec)
    end
  end

  describe "updateProcess" do
    test "update an existing process" do
      user = fake_user!()
      spec = fake_process!(user)

      q = update_process_mutation()
      conn = user_conn(user)
      vars = %{process: process_input(%{"id" => spec.id})}
      assert spec = grumble_post_key(q, conn, :update_process, vars)["process"]
      assert_process(spec)
    end

    test "fail if has been deleted" do
      user = fake_user!()
      spec = fake_process!(user)

      q = update_process_mutation()
      conn = user_conn(user)
      vars = %{process: process_input(%{"id" => spec.id})}
      assert {:ok, spec} = Processes.soft_delete(spec)
      assert [%{"code" => "not_found", "path" => ["updateProcess"], "status" => 404}] =
              grumble_post_errors(q, conn, vars)
    end
  end

  describe "deleteProcess" do
    test "deletes an existing process" do
      user = fake_user!()
      spec = fake_process!(user)

      q = delete_process_mutation()
      conn = user_conn(user)
      assert grumble_post_key(q, conn, :delete_process, %{id: spec.id})
    end
  end


end
