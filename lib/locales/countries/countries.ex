defmodule CommonsPub.Locales.Countries do
  # import Ecto.Query
  # alias Ecto.Changeset
  alias MoodleNet.{
    # Common, GraphQL,
    Repo
  }

  alias CommonsPub.Locales.Country
  alias CommonsPub.Locales.Countries.Queries

  def get(id), do: one(id: String.downcase(id))

  def one(filters), do: Repo.single(Queries.query(Country, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Country, filters))}

  @ascii_letters_start 65
  @emoji_letters_start 127_462

  def emoji_flag(country_code) when is_atom(country_code),
    do: emoji_flag(Atom.to_string(country_code))

  def emoji_flag(country_code) when is_binary(country_code),
    do: make_flag(String.upcase(country_code))

  defp make_flag(country_code, acc \\ <<>>)
  defp make_flag(<<>>, acc), do: acc

  defp make_flag(<<c, str::binary>>, acc) do
    make_flag(str, acc <> <<c - @ascii_letters_start + @emoji_letters_start::utf8>>)
  end
end
