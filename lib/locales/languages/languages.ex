defmodule Locales.Languages do
  import Ecto.Query
  alias Ecto.Changeset
  alias MoodleNet.{Common, GraphQL, Repo}
  alias MoodleNet.Batching.{Edges, EdgesPage, EdgesPages, NodesPage}
  # alias MoodleNet.Meta.{Pointer, Pointers, TableService}
  # alias MoodleNet.Users.User
  alias Locales.Language
  alias Locales.Languages.Queries

  def one(filters), do: Repo.single(Queries.query(Language, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Language, filters))}




end
