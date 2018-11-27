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

communities = for _ <- 1..3, do: Factory.community()
collections = for _ <- 1..5, do: Factory.collection(Enum.random(communities))
_resources = for _ <- 1..10, do: Factory.resource(Enum.random(collections))

actors = for _ <- 1..5, do: Factory.actor()

commentables = communities ++ collections

_comments = for _ <- 1..10, do: Factory.comment(Enum.random(actors), Enum.random(commentables))
