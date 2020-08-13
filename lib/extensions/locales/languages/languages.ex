defmodule CommonsPub.Locales.Languages do
  # import Ecto.Query
  # alias Ecto.Changeset
  alias MoodleNet.{
    # Common, GraphQL,
    Repo
  }

  alias CommonsPub.Locales.Language
  alias CommonsPub.Locales.Languages.Queries

  def get(id), do: one(id: String.downcase(id))

  def one(filters), do: Repo.single(Queries.query(Language, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Language, filters))}
end
