# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.UploadsTest do
  use MoodleNetWeb.ConnCase, async: true

  import MoodleNet.Test.Faking
  import MoodleNetWeb.Test.ConnHelpers
  alias MoodleNet.Uploads
  alias MoodleNet.Uploads.Storage

  # # TODO: delete upload directory

  def upload_query(parent, file) do
    query = """
    mutation {
      uploadFile(contextId: \"#{parent.id}\", upload: \"file\") {
        id
        url
        media_type
        size
        metadata {
          width_px
          height_px
        }
      }
    }
    """

    %{
      query: query,
      variables: %{"upload" => "file"},
      file: file
    }
  end

  def assert_valid_url(url) do
    uri = URI.parse(url)
    assert uri.scheme
    assert uri.host
    assert uri.path
  end

  setup_all do
    on_exit(fn ->
      Storage.delete_all()
    end)
  end

  describe "upload" do
    test "upload an image for an existing object" do
      user = fake_user!()
      file = %Plug.Upload{
        path: "test/fixtures/images/150.png",
        filename: "150.png",
        content_type: "image/png"
      }
      query = upload_query(user, file)
      conn = user_conn(user)

      assert resp = gql_post_data(conn, query)
      refute Map.has_key?(resp, "errors")
      assert %{"uploadFile" => upload} = resp

      assert upload["id"]
      # FIXME: support scope
      # assert upload["url"] =~ "#{user.id}/#{file.filename}"
      assert_valid_url upload["url"]
      assert upload["size"]
      assert upload["metadata"]["width_px"]
      assert upload["metadata"]["height_px"]

      # fetch_query = """
      # query {
      #   user(contextId: #{user.id}) {
      #     image
      #   }
      # }
      # """
      # assert resp = gql_post_data(conn, %{query: fetch_query})
      # assert get_in(resp, ["data", "user", "image"]) == url
    end

    test "fails with an invalid file extension" do
      user = fake_user!()
      file = %Plug.Upload{
        path: "test/fixtures/not-a-virus.exe",
        filename: "not-a-virus.exe",
        content_type: "application/executable"
      }
      query = upload_query(user, file)
      conn = user_conn(user)

      assert [%{"message" => "extension_denied"}] = gql_post_errors(conn, query)
    end

    test "fails with an missing file" do
      user = fake_user!()
      file = %Plug.Upload{
        path: "missing.png",
        filename: "missing.png",
        content_type: "image/png"
      }
      query = upload_query(user, file)
      conn = user_conn(user)

      assert [%{"message" => "enoent"}] = gql_post_errors(conn, query)
    end
  end
end
