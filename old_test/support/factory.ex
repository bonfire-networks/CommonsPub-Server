defmodule MoodleNet.Factory do
  use ExMachina.Ecto, repo: MoodleNet.Repo

  def user_factory do
    user = %MoodleNet.Accounts.User{
      name: sequence(:name, &"Test テスト User #{&1}"),
      email: sequence(:email, &"user#{&1}@example.com"),
      nickname: sequence(:nickname, &"nick#{&1}"),
      bio: sequence(:bio, &"Tester Number #{&1}")
    }

    %{
      user
      | ap_id: MoodleNet.Accounts.User.ap_id(user),
        follower_address: MoodleNet.Accounts.User.ap_followers(user),
        following: [MoodleNet.Accounts.User.ap_id(user)]
    }
  end

  def note_factory do
    text = sequence(:text, &"This is :moominmamma: note #{&1}")

    user = insert(:user)

    data = %{
      "type" => "Note",
      "content" => text,
      "id" => ActivityPub.Utils.generate_object_id(),
      "actor" => user.ap_id,
      "to" => ["https://www.w3.org/ns/activitystreams#Public"],
      "published" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "likes" => [],
      "like_count" => 0,
      "context" => "2hu",
      "summary" => "2hu",
      "tag" => ["2hu"],
      "emoji" => %{
        "2hu" => "corndog.png"
      }
    }

    %ActivityPub.Object{
      data: data
    }
  end

  def direct_note_factory do
    user2 = insert(:user)

    %ActivityPub.Object{data: data} = note_factory()
    %ActivityPub.Object{data: Map.merge(data, %{"to" => [user2.ap_id]})}
  end

  def direct_note_activity_factory do
    dm = insert(:direct_note)

    data = %{
      "id" => ActivityPub.Utils.generate_activity_id(),
      "type" => "Create",
      "actor" => dm.data["actor"],
      "to" => dm.data["to"],
      "object" => dm.data,
      "published" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "context" => dm.data["context"]
    }

    %MoodleNet.Activity{
      data: data,
      actor: data["actor"],
      recipients: data["to"]
    }
  end

  def note_activity_factory do
    note = insert(:note)

    data = %{
      "id" => ActivityPub.Utils.generate_activity_id(),
      "type" => "Create",
      "actor" => note.data["actor"],
      "to" => note.data["to"],
      "object" => note.data,
      "published" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "context" => note.data["context"]
    }

    %MoodleNet.Activity{
      data: data,
      actor: data["actor"],
      recipients: data["to"]
    }
  end

  def announce_activity_factory do
    note_activity = insert(:note_activity)
    user = insert(:user)

    data = %{
      "type" => "Announce",
      "actor" => note_activity.actor,
      "object" => note_activity.data["id"],
      "to" => [user.follower_address, note_activity.data["actor"]],
      "cc" => ["https://www.w3.org/ns/activitystreams#Public"],
      "context" => note_activity.data["context"]
    }

    %MoodleNet.Activity{
      data: data,
      actor: user.ap_id,
      recipients: data["to"]
    }
  end

  def like_activity_factory do
    note_activity = insert(:note_activity)
    user = insert(:user)

    data = %{
      "id" => ActivityPub.Utils.generate_activity_id(),
      "actor" => user.ap_id,
      "type" => "Like",
      "object" => note_activity.data["object"]["id"],
      "published_at" => DateTime.utc_now() |> DateTime.to_iso8601()
    }

    %MoodleNet.Activity{
      data: data
    }
  end

  def follow_activity_factory do
    follower = insert(:user)
    followed = insert(:user)

    data = %{
      "id" => ActivityPub.Utils.generate_activity_id(),
      "actor" => follower.ap_id,
      "type" => "Follow",
      "object" => followed.ap_id,
      "published_at" => DateTime.utc_now() |> DateTime.to_iso8601()
    }

    %MoodleNet.Activity{
      data: data,
      actor: follower.ap_id
    }
  end

  def oauth_app_factory do
    %MoodleNet.OAuth.App{
      client_name: "Some client",
      redirect_uri: "https://example.com/callback",
      scopes: "read",
      website: "https://example.com",
      client_id: "aaabbb==",
      client_secret: "aaa;/&bbb"
    }
  end
end
