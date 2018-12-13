defmodule ActivityPubWeb.ActorControllerTest do
  use MoodleNetWeb.ConnCase, async: true

  describe "show" do
    @tag format: :json_ld
    test "it works with json", %{conn: conn} do
      user = Factory.user()

      assert resp =
               conn
               |> get("/actors/#{user.primary_actor_id}")
               |> json_response(200)

      assert resp["id"] == user.primary_actor.uri
    end

    @tag format: :html
    test "it works with html", %{conn: conn} do
      user = Factory.user()

      assert conn
      |> get("/actors/#{user.primary_actor_id}")
      |> html_response(200) =~ user.primary_actor.uri
    end
  end
end
