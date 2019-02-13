defmodule ActivityPub.ApplyActionTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.SQL.{Query}

  import ActivityPub, only: [apply: 1]

  describe "audiences" do
    test "sends the activity to every person" do
      to = Factory.actor()
      bto = Factory.actor()
      cc = Factory.actor()
      bcc = Factory.actor()
      audience = Factory.actor()

      follow = %{
        type: "Follow",
        actor: to,
        object: bto,
        to: to,
        bto: bto,
        cc: cc,
        bcc: bcc,
        audience: audience,
      }

      assert {:ok, follow} = ActivityPub.new(follow)
      assert {:ok, follow} = apply(follow)

      assert Query.has?(to, :inbox, follow)
      assert Query.has?(bto, :inbox, follow)
      assert Query.has?(cc, :inbox, follow)
      assert Query.has?(bcc, :inbox, follow)
      assert Query.has?(audience, :inbox, follow)
    end

    test "sends the activity to every collection" do
      to = Factory.actor()
      to_follower = Factory.actor()
      follow = %{type: "Follow", actor: to_follower, object: to}
      assert {:ok, follow} = ActivityPub.new(follow)
      assert {:ok, _} = apply(follow)

      bto = Factory.actor()
      bto_follower = Factory.actor()
      follow = %{type: "Follow", actor: bto_follower, object: bto}
      assert {:ok, follow} = ActivityPub.new(follow)
      assert {:ok, _} = apply(follow)

      cc = Factory.actor()
      cc_follower = Factory.actor()
      follow = %{type: "Follow", actor: cc_follower, object: cc}
      assert {:ok, follow} = ActivityPub.new(follow)
      assert {:ok, _} = apply(follow)

      bcc = Factory.actor()
      bcc_follower = Factory.actor()
      follow = %{type: "Follow", actor: bcc_follower, object: bcc}
      assert {:ok, follow} = ActivityPub.new(follow)
      assert {:ok, _} = apply(follow)

      audience = Factory.actor()
      audience_follower = Factory.actor()
      follow = %{type: "Follow", actor: audience_follower, object: audience}
      assert {:ok, follow} = ActivityPub.new(follow)
      assert {:ok, _} = apply(follow)

      like = %{
        type: "Like",
        actor: to,
        object: bto,
        to: to.followers,
        bto: bto.followers,
        cc: cc.followers,
        bcc: bcc.followers,
        audience: audience.followers,
      }

      assert {:ok, like} = ActivityPub.new(like)
      assert {:ok, like} = apply(like)

      assert Query.has?(to_follower, :inbox, like)
      assert Query.has?(bto_follower, :inbox, like)
      assert Query.has?(cc_follower, :inbox, like)
      assert Query.has?(bcc_follower, :inbox, like)
      assert Query.has?(audience_follower, :inbox, like)

      refute Query.has?(to, :inbox, like)
      refute Query.has?(bto, :inbox, like)
      refute Query.has?(cc, :inbox, like)
      refute Query.has?(bcc, :inbox, like)
      refute Query.has?(audience, :inbox, like)
    end
  end

  describe "follow" do
    test "works" do
      follower_actor = Factory.actor()
      following_actor = Factory.actor()

      follow = %{
        type: "Follow",
        actor: follower_actor,
        object: following_actor,
        to: [following_actor],
        _public: true
      }

      assert {:ok, follow} = ActivityPub.new(follow)
      assert {:ok, follow} = apply(follow)

      refute Query.has?(follower_actor, :followers, following_actor)
      refute Query.has?(following_actor, :following, follower_actor)
      assert Query.has?(following_actor, :followers, follower_actor)
      assert Query.has?(follower_actor, :following, following_actor)

      assert Query.has?(follower_actor, :outbox, follow)
      assert Query.has?(following_actor, :inbox, follow)

      undo = %{
        type: "Undo",
        actor: follower_actor,
        object: follow
      }

      assert {:ok, undo} = ActivityPub.new(undo)
      assert {:ok, _undo} = apply(undo)

      refute Query.has?(following_actor, :followers, follower_actor)
      refute Query.has?(follower_actor, :following, following_actor)
    end
  end

  describe "like" do
    test "works" do
      liker_actor = Factory.actor()
      liked_actor = Factory.actor()

      like = %{
        type: "Like",
        actor: liker_actor,
        object: liked_actor
      }

      assert {:ok, like} = ActivityPub.new(like)
      assert {:ok, like} = apply(like)

      refute Query.has?(liker_actor, :likers, liked_actor)
      refute Query.has?(liked_actor, :liked, liker_actor)
      assert Query.has?(liker_actor, :liked, liked_actor)
      assert Query.has?(liked_actor, :likers, liker_actor)

      undo = %{
        type: "Undo",
        actor: liker_actor,
        object: like
      }

      assert {:ok, undo} = ActivityPub.new(undo)
      assert {:ok, _undo} = apply(undo)

      refute Query.has?(liker_actor, :liked, liked_actor)
      refute Query.has?(liked_actor, :likers, liker_actor)
    end
  end

  describe "create" do
    @tag skip: "TO DO"
    test "works" do
    end
  end
end
