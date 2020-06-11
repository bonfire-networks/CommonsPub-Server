defmodule Locales.Countries do
  import Ecto.Query
  alias Ecto.Changeset
  alias MoodleNet.{Common, GraphQL, Repo}
  alias MoodleNet.Batching.{Edges, EdgesPage, EdgesPages, NodesPage}
  # alias MoodleNet.Meta.{Pointer, Pointers, TableService}
  # alias MoodleNet.Users.User
  alias Locales.Country
  alias Locales.Countries.Queries

  def one(filters), do: Repo.single(Queries.query(Country, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Country, filters))}



end
