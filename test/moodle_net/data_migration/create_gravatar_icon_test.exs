defmodule MoodleNet.DataMigration.CreateGravatarIconTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.SQL.{Query}

  test "works" do
    actor = Factory.actor(email: "alex@moodle.com")
    for _ <- 1..100, do: Factory.actor()

    Query.new()
    |> Query.with_type("Image")
    |> Query.delete_all()

    actor = Query.reload(actor) |> Query.preload_assoc(:icon)
    assert actor.icon == []

    MoodleNet.DataMigration.CreateGravatarIcon.call()
    actor = Query.reload(actor) |> Query.preload_assoc(:icon)
    assert [icon] = actor.icon
    assert ["https://s.gravatar.com/avatar/7779b850ea05dbeca7fc39a910a77f21?d=identicon&r=g&s=80"] == icon.url
  end
end
