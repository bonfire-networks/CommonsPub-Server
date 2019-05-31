# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Pleroma.Repo.insert!(%Pleroma.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias MoodleNet.Factory

MoodleNet.Repo.transaction(fn ->
  actors = for _ <- 1..5, do: Factory.actor()

  communities = for _ <- 1..3, do: Factory.community(Enum.random(actors))
  for a <- actors, c <- communities, do: MoodleNet.join_community(a, c)

  collections =
    for _ <- 1..5,
        do:
          Factory.collection(
            Enum.random(actors),
            Enum.random(communities)
          )

  _resources = for _ <- 1..10, do: Factory.resource(Enum.random(actors), Enum.random(collections))

  commentables = communities ++ collections

  threads = for _ <- 1..10, do: Factory.comment(Enum.random(actors), Enum.random(commentables))
  replies = for _ <- 1..10, do: Factory.reply(Enum.random(actors), Enum.random(threads))
  _replies = for _ <- 1..10, do: Factory.reply(Enum.random(actors), Enum.random(replies))
  {:ok, nil}
end)
