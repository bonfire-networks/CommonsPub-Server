# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.AccountTest do
  use MoodleNetWeb.ConnCase

  @moduletag format: :json

  alias MoodleNet.Repo

  test "confirm email", %{conn: conn} do
    query = """
    mutation {
      confirmEmail(token: "not_real_token")
    }
    """

    assert [
             %{
               "code" => "not_found",
               "extra" => %{"type" => "Token", "value" => "not_real_token"},
               "message" => "Token not found"
             }
           ] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("errors")

    %{email_confirmation_token: %{token: token}} = Factory.full_user()

    query = """
    mutation {
      confirmEmail(token: "#{token}")
    }
    """

    assert true =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("confirmEmail")
  end

  test "reset password flow", %{conn: conn} do
    query = """
    mutation {
      resetPasswordRequest(email: "not_real@email.es")
    }
    """

    assert true =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("resetPasswordRequest")

    user = Factory.user()

    query = """
    mutation {
      resetPasswordRequest(email: "#{user.email}")
    }
    """

    assert true =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("resetPasswordRequest")

    assert %{token: token} = Repo.get_by!(MoodleNet.Accounts.ResetPasswordToken, user_id: user.id)

    query = """
    mutation {
      resetPassword(
        token: "#{token}"
        password: "new_password"
      )
    }
    """

    assert true =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("resetPassword")

    query = """
    mutation {
      resetPassword(
        token: "not_real_token"
        password: "new_password"
      )
    }
    """

    assert [
             %{
               "code" => "not_found",
               "extra" => %{"type" => "Token", "value" => "not_real_token"},
               "message" => "Token not found"
             }
           ] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("errors")
  end

  test "delete an account", %{conn: conn} do
    actor = Factory.actor()
    community = Factory.community(actor)
    comment = Factory.comment(actor, community)

    query = """
      mutation {
        createSession(
          email: "#{actor["email"]}"
          password: "password"
        ) {
          token
        }
      }
    """

    assert token =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("createSession")
             |> Map.fetch!("token")

    conn = conn |> put_req_header("authorization", "Bearer #{token}")

    query = """
      mutation {
        deleteUser
      }
    """

    assert true ==
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("deleteUser")

    query = """
    {
      me {
        email
      }
    }
    """

    assert [
             %{
               "code" => "unauthorized",
               "message" => "You need to log in first"
             }
           ] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("errors")

    query = """
    {
      comment(id: "#{comment.id}") {
        id
        content
      }
    }
    """

    assert ret =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("comment")

    assert ret["content"] == ""
  end

  test "delete session", %{conn: conn} do
    actor = Factory.actor()

    query = """
      mutation {
        createSession(
          email: "#{actor["email"]}"
          password: "password"
        ) {
          token
        }
      }
    """

    assert token =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("createSession")
             |> Map.fetch!("token")

    conn = conn |> put_req_header("authorization", "Bearer #{token}")

    query = """
      mutation {
        deleteSession
      }
    """

    assert true ==
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("deleteSession")

    assert [
             %{
               "code" => "unauthorized",
               "message" => "You need to log in first"
             }
           ] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("errors")
  end
end
