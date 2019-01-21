defmodule MoodleNetTest do
  use MoodleNet.DataCase, async: true

  describe "create_collection" do
    test "works" do
      owner = Factory.actor()
      comm = Factory.community(owner)

      attrs = Factory.attributes(:collection)
      actor = Factory.actor()
      assert {:error, :forbidden} = MoodleNet.create_collection(actor, comm, attrs)

      MoodleNet.join_community(actor, comm)

      assert {:ok, collection} = MoodleNet.create_collection(actor, comm, attrs)
      assert collection.name == %{"und" => attrs["name"]}
      assert collection.summary == %{"und" => attrs["summary"]}
      assert collection.content == %{"und" => attrs["content"]}
      assert collection.preferred_username == attrs["preferred_username"]
      assert collection["primary_language"] == attrs["primary_language"]
      url = get_in(collection, [:icon, Access.at(0), :url, Access.at(0)])
      assert url == attrs["icon"]["url"]
    end
  end

  describe "create_resource" do
    test "works" do
      owner = Factory.actor()
      comm = Factory.community(owner)
      coll = Factory.collection(owner, comm)

      attrs = Factory.attributes(:resource)

      actor = Factory.actor()
      assert {:error, :forbidden} = MoodleNet.create_resource(actor, coll, attrs)

      MoodleNet.join_community(actor, comm)

      assert {:ok, resource} = MoodleNet.create_resource(actor, coll, attrs)
      assert resource.name == %{"und" => attrs["name"]}
      assert resource.summary == %{"und" => attrs["summary"]}
      assert resource.content == %{"und" => attrs["content"]}
      assert resource.primary_language == attrs["primary_language"]
      url = get_in(resource, [:icon, Access.at(0), :url, Access.at(0)])
      assert url == attrs["icon"]["url"]
      assert resource.url == [attrs["url"]]
      assert resource.same_as == attrs["same_as"]
      assert resource.public_access == attrs["public_access"]
      assert resource.is_accesible_for_free == attrs["is_accesible_for_free"]
      assert resource.license == attrs["license"]
      assert resource.learning_resource_type == attrs["learning_resource_type"]
      assert resource.educational_use == attrs["educational_use"]
      assert resource.time_required == attrs["time_required"]
      assert resource.typical_age_range == attrs["typical_age_range"]
    end
  end

  describe "create_thread" do
    test "works" do
      owner = Factory.actor()
      comm = Factory.community(owner)
      coll = Factory.collection(owner, comm)

      attrs = Factory.attributes(:comment)

      actor = Factory.actor()
      assert {:error, :forbidden} = MoodleNet.create_thread(actor, comm, attrs)
      assert {:error, :forbidden} = MoodleNet.create_thread(actor, coll, attrs)

      MoodleNet.join_community(actor, comm)
      assert {:ok, comment} = MoodleNet.create_thread(actor, comm, attrs)
      assert comment["primary_language"] == attrs["primary_language"]
      assert comment.content == %{"und" => attrs["content"]}


      assert {:ok, comment} = MoodleNet.create_thread(actor, coll, attrs)
      assert comment["primary_language"] == attrs["primary_language"]
      assert comment.content == %{"und" => attrs["content"]}
    end
  end

  describe "create_reply" do
    test "works" do
      owner = Factory.actor()
      comm = Factory.community(owner)
      coll = Factory.collection(owner, comm)

      c1 = Factory.comment(owner, comm)
      c2 = Factory.comment(owner, coll)

      attrs = Factory.attributes(:comment)

      actor = Factory.actor()
      assert {:error, :forbidden} = MoodleNet.create_reply(actor, c1, attrs)
      assert {:error, :forbidden} = MoodleNet.create_reply(actor, c2, attrs)

      MoodleNet.join_community(actor, comm)
      assert {:ok, comment} = MoodleNet.create_reply(actor, c1, attrs)
      assert comment["primary_language"] == attrs["primary_language"]
      assert comment.content == %{"und" => attrs["content"]}


      assert {:ok, comment} = MoodleNet.create_reply(actor, c2, attrs)
      assert comment["primary_language"] == attrs["primary_language"]
      assert comment.content == %{"und" => attrs["content"]}
    end
  end

  describe "like_comment & undo" do
    test "works" do
      owner = Factory.actor()
      comm = Factory.community(owner)
      coll = Factory.collection(owner, comm)

      c1 = Factory.comment(owner, comm)
      c2 = Factory.comment(owner, coll)

      actor = Factory.actor()
      assert {:error, :forbidden} = MoodleNet.like_comment(actor, c1)
      assert {:error, :forbidden} = MoodleNet.like_comment(actor, c2)

      MoodleNet.join_community(actor, comm)

      assert {:ok, true} = MoodleNet.like_comment(actor, c1)
      assert {:ok, true} = MoodleNet.like_comment(actor, c2)

      assert {:ok, true} = MoodleNet.undo_like(actor, c1)
      assert {:ok, true} = MoodleNet.undo_like(actor, c2)

      assert {:error, {:not_found, _, "Activity"}} = MoodleNet.undo_like(actor, c1)
      assert {:error, {:not_found, _, "Activity"}} = MoodleNet.undo_like(actor, c2)
    end
  end

  describe "like_resource & undo" do
    test "works" do
      owner = Factory.actor()
      comm = Factory.community(owner)
      coll = Factory.collection(owner, comm)
      resource = Factory.resource(owner, coll)

      actor = Factory.actor()
      assert {:error, :forbidden} = MoodleNet.like_resource(actor, resource)

      MoodleNet.join_community(actor, comm)
      assert {:ok, true} = MoodleNet.like_resource(actor, resource)

      assert {:ok, true} = MoodleNet.undo_like(actor, resource)
      assert {:error, {:not_found, _, "Activity"}} = MoodleNet.undo_like(actor, resource)
    end
  end

  describe "join_community & undo" do
    test "works" do
      owner = Factory.actor()
      comm = Factory.community(owner)

      actor = Factory.actor()
      assert {:error, {:not_found, _, "Activity"}} = MoodleNet.undo_follow(actor, comm)
      assert {:ok, true} = MoodleNet.join_community(actor, comm)
      assert {:ok, true} = MoodleNet.join_community(actor, comm)
      assert {:ok, true} = MoodleNet.undo_follow(actor, comm)
      assert {:error, {:not_found, _, "Activity"}} = MoodleNet.undo_follow(actor, comm)
    end
  end

  describe "follow_collection & undo" do
    test "works" do
      owner = Factory.actor()
      comm = Factory.community(owner)
      coll = Factory.collection(owner, comm)

      actor = Factory.actor()
      assert {:error, {:not_found, _, "Activity"}} = MoodleNet.undo_follow(actor, coll)
      assert {:ok, true} = MoodleNet.follow_collection(actor, coll)
      assert {:ok, true} = MoodleNet.follow_collection(actor, coll)
      assert {:ok, true} = MoodleNet.undo_follow(actor, coll)
      assert {:error, {:not_found, _, "Activity"}} = MoodleNet.undo_follow(actor, coll)
    end
  end
end
