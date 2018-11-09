defmodule MoodleNetWeb.Accounts.UserControllerTest do
  use MoodleNetWeb.ConnCase
  alias MoodleNet.NewFactory, as: Factory

  describe "create" do
    test "works" do
      params = Factory.attributes(:user)
      conn
      |> post("/api/v1/users", %{"user" => params})
      |> json_response(201)
    end
  end
end
