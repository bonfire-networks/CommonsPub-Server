# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.UploadsTest do
  # use MoodleNetWeb.ConnCase, async: true

  # import MoodleNet.Test.Faking
  # import MoodleNetWeb.Test.ConnHelpers
  # alias MoodleNet.Uploads
  # alias MoodleNet.Uploads.Storage

  # # TODO: delete upload directory

  # def upload_query(parent, file) do
  #   query = """
  #   mutation {
  #     uploadFile(contextId: \"#{parent.id}\", file: \"file\")
  #   }
  #   """

  #   %{
  #     "query" => query,
  #     "variables" => %{"file" => "file"},
  #     "file" => file
  #   }
  # end

  # def assert_valid_url(url) do
  #   uri = URI.parse(url)
  #   assert uri.scheme
  #   assert uri.host
  #   assert uri.path
  # end

  # setup_all do
  #   on_exit(fn ->
  #     Storage.delete_all()
  #   end)
  # end

  # describe "upload" do
  #   test "upload an image for an existing object" do
  #     actor = fake_actor!()
  #     file = %Plug.Upload{
  #       path: "test/fixtures/images/150.png",
  #       filename: "150.png",
  #       content_type: "image/png"
  #     }
  #     query = upload_query(actor, file)

  #     assert resp = gql_post_data(query)
  #     refute Map.has_key?(resp, "errors")
  #     assert %{"data" => %{"upload" => url}} = resp
  #     assert url =~ "#{actor.id}/#{file.filename}"
  #     assert_valid_url url

  #     fetch_query = """
  #     query {
  #       user(contextId: #{actor.id}) {
  #         image
  #       }
  #     }
  #     """
  #     assert resp = gql_post_data(%{query: fetch_query})
  #     assert get_in(resp, ["data", "user", "image"]) == url
  #   end

  #   test "fails with an invalid file extension" do
  #     actor = fake_actor!()
  #     file = %Plug.Upload{
  #       path: "test/fixtures/not-a-virus.exe",
  #       filename: "not-a-virus.exe",
  #       content_type: "application/executable"
  #     }
  #     query = upload_query(actor, file)

  #     assert resp = gql_post_data(query)

  #     assert %{"errors" => [%{"message" => "invalid_file"}]} = resp
  #     assert %{"data" => %{"upload" => nil}} = resp
  #   end

  #   test "fails with an missing file" do
  #     actor = fake_actor!()
  #     file = %Plug.Upload{
  #       path: "missing.png",
  #       filename: "missing.png",
  #       content_type: "image/png"
  #     }
  #     query = upload_query(actor, file)

  #     assert resp = gql_post_data(query)
  #     assert %{"errors" => [%{"message" => "not_found"}]} = resp
  #     assert %{"data" => %{"upload" => nil}} = resp
  #   end
  # end
end
