# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.UploadsTest do
  use MoodleNetWeb.ConnCase, async: true

  import MoodleNet.Test.Faking
  import MoodleNetWeb.Test.ConnHelpers
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import Grumble
  alias MoodleNet.Uploads.Storage

  @image_file %{
    path: "test/fixtures/images/150.png",
    filename: "150.png",
    content_type: "image/png"
  }
  @image_url "https://upload.wikimedia.org/wikipedia/commons/e/e9/South_African_Airlink_Boeing_737-200_Advanced_Smith.jpg"

  def upload_fields(extra \\ []) do
    [:id, :url, :media_type, upload: [:path, :size], mirror: [:url]] ++ extra
  end

  def upload_mutation(mutation_name, options \\ []) do
    options = [mutation_name: mutation_name] ++ options

    [context_id: type!(:string), upload: type!(:upload)]
    |> gen_mutation(&upload_submutation/1, options)
  end

  def upload_submutation(options) do
    {mutation_name, options} = Keyword.pop!(options, :mutation_name)

    [context_id: var(:context_id), upload: var(:upload)]
    |> gen_submutation(mutation_name, &upload_fields/1, options)
  end


  def assert_content(content) do
    assert content["id"]
    assert_url content["url"]
  end

  def assert_content_upload(content, file) do
    assert content["mediaType"] == file.content_type
    assert content["upload"]["path"]
    assert content["upload"]["size"] > 0
  end

  def assert_content_mirror(content, url) do
    assert content["mirror"]["url"] == url
    assert content["mirror"]["url"] == content["url"]
  end

  setup_all do
    on_exit(fn ->
      Storage.delete_all()
    end)
  end

  describe "upload_icon" do
    test "for an upload" do
      user = fake_user!()
      query = upload_mutation(:upload_icon)
      conn = user_conn(user)

      assert content =
        grumble_post_key(query, conn, :upload_icon, %{context_id: user.id, upload: @image_file})
      assert_content(content)
      assert_content_upload(content, @image_file)
      assert content["url"] =~ "#{user.id}/#{@image_file.filename}"
      refute content["mirror"]["url"]

      assert {:ok, user} = MoodleNet.Users.one(id: user.id)
      assert user.icon_id == content["id"]
    end

    test "for a mirror" do
      user = fake_user!()
      query = upload_mutation(:upload_icon)
      conn = user_conn(user)

      params = %{context_id: user.id, upload: %{url: @image_url}}
      assert content = grumble_post_key(query, conn, :upload_icon, params)
      assert_content(content)
      assert_content_mirror(content, get_in(params, [:upload, :url]))
    end

    test "upload fails with an invalid file extension" do
      user = fake_user!()
      file = %{
        path: "test/fixtures/not-a-virus.exe",
        filename: "not-a-virus.exe",
        content_type: "application/executable"
      }
      query = upload_mutation(:upload_icon)
      conn = user_conn(user)

      assert [%{"message" => "extension_denied"}] =
        grumble_post_errors(query, conn, %{context_id: user.id, upload: file})
    end

    # FIXME
    test "mirror fails with an invalid file extension" do
      user = fake_user!()
      file = %{url: "https://raw.githubusercontent.com/antoniskalou/format_parser.ex/master/README.md"}
      query = upload_mutation(:upload_icon)
      conn = user_conn(user)

      assert [%{"message" => "extension_denied"}] =
        grumble_post_errors(query, conn, %{context_id: user.id, upload: file})
    end

    test "upload fails with a missing file" do
      user = fake_user!()
      file = %{
        path: "missing.png",
        filename: "missing.png",
        content_type: "image/png"
      }
      query = upload_mutation(:upload_icon)
      conn = user_conn(user)

      assert [%{"message" => "enoent"}] =
        grumble_post_errors(query, conn, %{context_id: user.id, upload: file})
    end

    test "mirror fails with a 404 link" do
      user = fake_user!()
      file = %{url: "http://example.org/missing.png"}
      query = upload_mutation(:upload_icon)
      conn = user_conn(user)

      assert [%{"message" => "enoent"}] =
        grumble_post_errors(query, conn, %{context_id: user.id, upload: file})
    end
  end

  describe "upload_image" do
    test "for an upload" do
      user = fake_user!()
      comm = fake_community!(user)
      query = upload_mutation(:upload_image)
      conn = user_conn(user)

      assert content =
        grumble_post_key(query, conn, :upload_image, %{context_id: comm.id, upload: @image_file})

      assert_content(content)
      assert_content_upload(content, @image_file)
      assert content["url"] =~ "#{user.id}/#{@image_file.filename}"

      assert {:ok, comm} = MoodleNet.Communities.one(id: comm.id)
      assert comm.image_id == content["id"]
    end

    test "for a mirror" do
      user = fake_user!()
      comm = fake_community!(user)
      query = upload_mutation(:upload_image)
      conn = user_conn(user)

      params = %{context_id: comm.id, upload: %{url: @image_url}}
      assert content = grumble_post_key(query, conn, :upload_image, params)
      assert_content(content)
      assert_content_mirror(content, get_in(params, [:upload, :url]))

      assert {:ok, comm} = MoodleNet.Communities.one(id: comm.id)
      assert comm.image_id == content["id"]
    end

    test "fails with an invalid file extension" do
      user = fake_user!()
      comm = fake_community!(user)
      file = %{
        path: "test/fixtures/not-a-virus.exe",
        filename: "not-a-virus.exe",
        content_type: "application/executable"
      }
      query = upload_mutation(:upload_image)
      conn = user_conn(user)

      assert [%{"message" => "extension_denied"}] =
        grumble_post_errors(query, conn, %{context_id: comm.id, upload: file})
    end

    test "fails with an missing file" do
      user = fake_user!()
      comm = fake_community!(user)
      file = %{
        path: "missing.png",
        filename: "missing.png",
        content_type: "image/png"
      }
      query = upload_mutation(:upload_image)
      conn = user_conn(user)

      assert [%{"message" => "enoent"}] =
        grumble_post_errors(query, conn, %{context_id: comm.id, upload: file})
    end
  end

  describe "upload_resource" do
    test "for an existing object" do
      user = fake_user!()
      comm = fake_community!(user)
      coll = fake_collection!(user, comm)
      res = fake_resource!(user, coll)
      query = upload_mutation(:upload_resource)
      conn = user_conn(user)

      assert content =
        grumble_post_key(query, conn, :upload_resource, %{context_id: res.id, upload: @image_file})

      assert_content(content)
      assert_content_upload(content, @image_file)
      assert content["url"] =~ "#{user.id}/#{@image_file.filename}"

      assert {:ok, res} = MoodleNet.Resources.one(id: res.id)
      assert res.content_id == content["id"]
    end

    test "works with PDF files" do
      user = fake_user!()
      comm = fake_community!(user)
      coll = fake_collection!(user, comm)
      res = fake_resource!(user, coll)
      file = %{
        path: "test/fixtures/very-important.pdf",
        filename: "150.png",
        content_type: "image/png"
      }
      query = upload_mutation(:upload_resource)
      conn = user_conn(user)

      assert grumble_post_key(query, conn, :upload_resource, %{context_id: res.id, upload: file})
    end

    test "fails with an invalid file extension" do
      user = fake_user!()
      comm = fake_community!(user)
      coll = fake_collection!(user, comm)
      res = fake_resource!(user, coll)
      file = %{
        path: "test/fixtures/not-a-virus.exe",
        filename: "not-a-virus.exe",
        content_type: "application/executable"
      }
      query = upload_mutation(:upload_resource)
      conn = user_conn(user)

      assert [%{"message" => "extension_denied"}] =
        grumble_post_errors(query, conn, %{context_id: res.id, upload: file})
    end

    test "fails with an missing file" do
      user = fake_user!()
      comm = fake_community!(user)
      coll = fake_collection!(user, comm)
      res = fake_resource!(user, coll)
      file = %{
        path: "missing.png",
        filename: "missing.png",
        content_type: "image/png"
      }
      query = upload_mutation(:upload_resource)
      conn = user_conn(user)

      assert [%{"message" => "enoent"}] =
        grumble_post_errors(query, conn, %{context_id: res.id, upload: file})
    end
  end

  describe "content.uploader" do
    test "returns the uploader for a content item" do
      user = fake_user!()
      query = upload_mutation(:upload_icon, fields: [uploader: [:id]])
      conn = user_conn(user)

      assert %{"uploader" => uploader} =
        grumble_post_key(query, conn, :upload_icon, %{context_id: user.id, upload: @image_file})

      assert uploader["id"] == user.id
    end
  end

  describe "content.url" do
    test "returns the remote URL for an upload" do
      user = fake_user!()
      query = upload_mutation(:upload_icon)
      conn = user_conn(user)

      assert content =
        grumble_post_key(query, conn, :upload_icon, %{context_id: user.id, upload: @image_file})
      assert_url content["url"]
    end

    test "returns the remote URL for a mirror" do
      user = fake_user!()
      query = upload_mutation(:upload_icon)
      conn = user_conn(user)

      params = %{context_id: user.id, upload: %{url: @image_url}}
      assert content = grumble_post_key(query, conn, :upload_icon, params)
      assert_content(content)
      assert_content_mirror(content, get_in(params, [:upload, :url]))
    end
  end
end
