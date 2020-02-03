# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.UploadsTest do
  use MoodleNetWeb.ConnCase, async: true
  @moduletag :skip

  import MoodleNet.Test.Faking
  import MoodleNetWeb.Test.ConnHelpers
  alias MoodleNet.Uploads.Storage

  def upload_query(parent, file, mutation_name) do
    query = """
    mutation {
      #{mutation_name}(contextId: \"#{parent.id}\", upload: \"file\") {
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

  describe "upload_icon" do
    test "for an existing object" do
      user = fake_user!()
      file = %Plug.Upload{
        path: "test/fixtures/images/150.png",
        filename: "150.png",
        content_type: "image/png"
      }
      query = upload_query(user, file, "uploadIcon")
      conn = user_conn(user)

      assert resp = gql_post_data(conn, query)
      refute Map.has_key?(resp, "errors")
      assert %{"uploadIcon" => upload} = resp

      assert upload["id"]
      assert upload["url"] =~ "#{user.id}/#{file.filename}"
      assert_valid_url upload["url"]
      assert upload["size"]
      # assert upload["metadata"]["width_px"]
      # assert upload["metadata"]["height_px"]

      assert {:ok, user} = MoodleNet.Users.one(id: user.id)
      assert user.icon == upload["url"]
    end

    test "fails with an invalid file extension" do
      user = fake_user!()
      file = %Plug.Upload{
        path: "test/fixtures/not-a-virus.exe",
        filename: "not-a-virus.exe",
        content_type: "application/executable"
      }
      query = upload_query(user, file, "uploadIcon")
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
      query = upload_query(user, file, "uploadIcon")
      conn = user_conn(user)

      assert [%{"message" => "enoent"}] = gql_post_errors(conn, query)
    end
  end

  describe "upload_image" do
    test "for an existing object" do
      user = fake_user!()
      comm = fake_community!(user)
      file = %Plug.Upload{
        path: "test/fixtures/images/150.png",
        filename: "150.png",
        content_type: "image/png"
      }
      query = upload_query(comm, file, "uploadImage")
      conn = user_conn(user)

      assert resp = gql_post_data(conn, query)
      refute Map.has_key?(resp, "errors")
      assert %{"uploadImage" => upload} = resp

      assert upload["id"]
      assert upload["url"] =~ "#{comm.id}/#{file.filename}"
      assert_valid_url upload["url"]
      assert upload["size"]
      # assert upload["metadata"]["width_px"]
      # assert upload["metadata"]["height_px"]

      assert {:ok, comm} = MoodleNet.Communities.one(id: comm.id)
      assert comm.image == upload["url"]
    end

    test "fails with an invalid file extension" do
      user = fake_user!()
      comm = fake_community!(user)
      file = %Plug.Upload{
        path: "test/fixtures/not-a-virus.exe",
        filename: "not-a-virus.exe",
        content_type: "application/executable"
      }
      query = upload_query(comm, file, "uploadImage")
      conn = user_conn(user)

      assert [%{"message" => "extension_denied"}] = gql_post_errors(conn, query)
    end

    test "fails with an missing file" do
      user = fake_user!()
      comm = fake_community!(user)
      file = %Plug.Upload{
        path: "missing.png",
        filename: "missing.png",
        content_type: "image/png"
      }
      query = upload_query(comm, file, "uploadImage")
      conn = user_conn(user)

      assert [%{"message" => "enoent"}] = gql_post_errors(conn, query)
    end
  end

  describe "upload_resource" do
    test "for an existing object" do
      user = fake_user!()
      comm = fake_community!(user)
      coll = fake_collection!(user, comm)
      res = fake_resource!(user, coll)
      file = %Plug.Upload{
        path: "test/fixtures/images/150.png",
        filename: "150.png",
        content_type: "image/png"
      }
      query = upload_query(res, file, "uploadResource")
      conn = user_conn(user)

      assert resp = gql_post_data(conn, query)
      refute Map.has_key?(resp, "errors")
      assert %{"uploadResource" => upload} = resp

      assert upload["id"]
      assert upload["url"] =~ "#{res.id}/#{file.filename}"
      assert_valid_url upload["url"]
      assert upload["size"]
      # assert upload["metadata"]["width_px"]
      # assert upload["metadata"]["height_px"]

      assert {:ok, res} = MoodleNet.Resources.one(id: res.id)
      assert res.url == upload["url"]
    end

    test "works with PDF files" do
      user = fake_user!()
      comm = fake_community!(user)
      coll = fake_collection!(user, comm)
      res = fake_resource!(user, coll)
      file = %Plug.Upload{
        path: "test/fixtures/very-important.pdf",
        filename: "150.png",
        content_type: "image/png"
      }
      query = upload_query(res, file, "uploadResource")
      conn = user_conn(user)

      assert %{"uploadResource" => _res} = gql_post_data(conn, query)
    end

    test "fails with an invalid file extension" do
      user = fake_user!()
      comm = fake_community!(user)
      coll = fake_collection!(user, comm)
      res = fake_resource!(user, coll)
      file = %Plug.Upload{
        path: "test/fixtures/not-a-virus.exe",
        filename: "not-a-virus.exe",
        content_type: "application/executable"
      }
      query = upload_query(res, file, "uploadResource")
      conn = user_conn(user)

      assert [%{"message" => "extension_denied"}] = gql_post_errors(conn, query)
    end

    test "fails with an missing file" do
      user = fake_user!()
      comm = fake_community!(user)
      coll = fake_collection!(user, comm)
      res = fake_resource!(user, coll)
      file = %Plug.Upload{
        path: "missing.png",
        filename: "missing.png",
        content_type: "image/png"
      }
      query = upload_query(res, file, "uploadResource")
      conn = user_conn(user)

      assert [%{"message" => "enoent"}] = gql_post_errors(conn, query)
    end
  end
end
