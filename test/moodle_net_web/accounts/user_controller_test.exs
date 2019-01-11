defmodule MoodleNetWeb.Accounts.UserControllerTest do
  use MoodleNetWeb.ConnCase

  @tag format: :json
  describe "new" do
    test "does not accept json format", %{conn: conn} do
      assert_raise Phoenix.NotAcceptableError, fn ->
        get(conn, "api/v1/users/new")
      end
    end
  end

  describe "create" do
    @tag format: :json
    test "works", %{conn: conn} do
      params = Factory.attributes(:user)

      assert ret =
               conn
               |> post("/api/v1/users", %{"user" => params})
               |> json_response(201)

      assert %{
               "user" => user,
               "token" => token
               # "actor" => actor
             } = ret

      # assert actor["preferred_username"] == params["username"]
      assert user["email"] == params["email"]

      assert %{"token_type" => "Bearer", "access_token" => _} = token
    end

    @tag format: :json
    test "returns errors", %{conn: conn} do
      params = Factory.attributes(:user, password: "short")

      assert ret =
               conn
               |> post("/api/v1/users", %{"user" => params})
               |> json_response(422)

      assert %{
               "error_code" => "validation_errors",
               "error_message" => "Validation errors",
               "errors" => %{"password" => ["should be at least 6 character(s)"]}
             } = ret
    end
  end
end

defmodule MoodleNetWeb.Accoutns.UserControllerIntegrationTest do
  use MoodleNetWeb.IntegrationCase, async: true

  @tag format: :html
  test "works", %{conn: conn} do
    params = %{
        email: "alex@moodle.net",
        password: "password",
        preferred_username: "alex"
      }

    conn
    |> get("api/v1/users/new")
    |> follow_form(%{user: params})
    |> assert_response(status: 200, html: params[:email])
  end
end
