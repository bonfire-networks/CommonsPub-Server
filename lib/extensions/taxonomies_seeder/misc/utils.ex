defmodule Taxonomy.Utils do
  use CommonsPub.Web, :controller

  def get(conn, _params) do
    s = "I a,m! the bÉst? 1"
    t = string_to_actor_name(s)

    {:ok, tags} = Taxonomy.TaxonomyTags.many()

    for item <- tags do
      IO.inspect(item.name)
      IO.inspect(string_to_actor_name(item.name))
    end

    json(conn, t)
  end

  def string_to_actor_name(str) do
    Regex.replace(~r/[^a-zA-Z0-9]/u, upper_case_first_letter_of_words(str), "")
  end

  def upper_case_first_letter_of_words(str) do
    words = ~w(#{str})

    Enum.into(words, [], fn word -> first_char_to_uppercase(word) end)
    |> to_string
  end

  def first_char_to_uppercase(word) do
    code_points = String.codepoints(word)
    first = List.first(code_points)

    code_points
    |> List.replace_at(0, String.upcase(first))
    |> to_string
  end
end
