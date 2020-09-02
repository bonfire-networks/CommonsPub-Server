# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.WebFingerControllerTest do
  use CommonsPub.Web.ConnCase
  import CommonsPub.Test.Faking

  test "webfinger" do
    actor = fake_user!()

    response =
      build_conn()
      |> put_req_header("accept", "application/jrd+json")
      |> get("/.well-known/webfinger?resource=acct:#{actor.actor.preferred_username}@localhost")

    assert json_response(response, 200)["subject"] ==
             "acct:#{actor.actor.preferred_username}@localhost"
  end

  test "it returns 404 when user isn't found (JSON)" do
    result =
      build_conn()
      |> put_req_header("accept", "application/jrd+json")
      |> get("/.well-known/webfinger?resource=acct:jimm@localhost")
      |> json_response(404)

    assert result == "Couldn't find user"
  end
end
